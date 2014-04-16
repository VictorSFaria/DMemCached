{***************************************************************************}
{                                                                           }
{  DMemCached - Copyright (C) 2014 - Víctor de Souza Faria                  }
{                                                                           }
{  victor@victorfaria.com                                                   }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit DMemcached.Trasncoder;

interface

uses
  System.SysUtils;

type
  ITranscoder<T> = interface
    ['{AC9ED7AF-6E24-4B12-9109-38DEA0385657}']
    function ToBytes(value: T): TBytes;
    function ToObject(value: TBytes): T;
    function BytesSize(value: T): Word;
  end;

  TTranscoder = class(TInterfacedObject)
  public
    class function Default<T>: TTranscoder;
  end;

  TTrasncoderAnsiString = class(TTranscoder, ITranscoder<AnsiString>)
  public
    function ToBytes(value: AnsiString): TBytes;
    function ToObject(value: TBytes): AnsiString;
    function BytesSize(value: AnsiString): Word;
  end;

  TTrasncoderBool = class(TTranscoder, ITranscoder<Boolean>)
  public
    function ToBytes(value: Boolean): TBytes;
    function ToObject(value: TBytes): Boolean;
    function BytesSize(value: Boolean): Word;
  end;

  TTrasncoderDouble = class(TTranscoder, ITranscoder<Double>)
  public
    function ToBytes(value: Double): TBytes;
    function ToObject(value: TBytes): Double;
    function BytesSize(value: Double): Word;
  end;

  TTrasncoderDate = class(TTrasncoderDouble, ITranscoder<TDateTime>)
    function ToBytes(value: TDateTime): TBytes;
    function ToObject(value: TBytes): TDateTime;
    function BytesSize(value: TDateTime): Word;
  end;

  TTrasncoderInt32 = class(TTranscoder, ITranscoder<Int32>)
  public
    function ToBytes(value: Int32): TBytes;
    function ToObject(value: TBytes): Int32;
    function BytesSize(value: Int32): Word;
  end;

  TTrasncoderString = class(TTranscoder, ITranscoder<String>)
  public
    function ToBytes(value: String): TBytes;
    function ToObject(value: TBytes): String;
    function BytesSize(value: String): Word;
  end;

implementation

uses
  System.TypInfo;

{ TTrasncoderAnsiString }

function TTrasncoderAnsiString.BytesSize(value: AnsiString): Word;
begin
  Result := Length(value);
end;

function TTrasncoderAnsiString.ToBytes(value: AnsiString): TBytes;
begin
  Result := BytesOf(value);
end;

function TTrasncoderAnsiString.ToObject(value: TBytes): AnsiString;
begin
  Result := AnsiString(TEncoding.ANSI.GetString(value));
end;

{ TTrasncoderBool }

function TTrasncoderBool.BytesSize(value: Boolean): Word;
begin
  Result := 1;
end;

function TTrasncoderBool.ToBytes(value: Boolean): TBytes;
begin
  SetLength(Result, 1);
  if value then begin
    Result[0] := 1;
  end
  else begin
    Result[0] := 0;
  end;
end;

function TTrasncoderBool.ToObject(value: TBytes): Boolean;
begin
  Result := value[0] = 1;
end;


{ TTrasncoderInt }

function TTrasncoderInt32.BytesSize(value: Int32): Word;
begin
  Result := sizeof(value);
end;

function TTrasncoderInt32.ToBytes(value: Int32): TBytes;
begin
  SetLength(Result, 4);
  Result[0] := (value shr 24);
  Result[1] := (value shr 16);
  Result[2] := (value shr 8);
  Result[3] := (value);
end;

function TTrasncoderInt32.ToObject(value: TBytes): Int32;
begin
  Result := (value[0] shl 24) or ( value[1] shl 16) or (value[2] shl 8) or value[3];
end;

{ TTrasncoderString }

function TTrasncoderString.BytesSize(value: String): Word;
begin
  Result := Length(value) * sizeOf(Char);
end;

function TTrasncoderString.ToBytes(value: String): TBytes;
begin
  Result := WideBytesOf(value);
end;

function TTrasncoderString.ToObject(value: TBytes): String;
begin
  Result := TEncoding.Unicode.GetString(value);
end;

{ TTrasncoderDouble }

function TTrasncoderDouble.BytesSize(value: Double): Word;
begin
  Result := SizeOf(value);
end;

function TTrasncoderDouble.ToBytes(value: Double): TBytes;
var
  i: Integer;
begin
  SetLength(Result, SizeOf(value));
  for i := 0 to  SizeOf(value) - 1 do begin
    Result[i] := value.Bytes[i];
  end;
end;

function TTrasncoderDouble.ToObject(value: TBytes): Double;
var
  i: Integer;
begin
  for i := 0 to Length(value) - 1 do begin
    Result.Bytes[i] := value[i];
  end;
end;

{ TTrasncoderDate }

function TTrasncoderDate.BytesSize(value: TDateTime): Word;
begin
  Result := inherited BytesSize(value);
end;

function TTrasncoderDate.ToBytes(value: TDateTime): TBytes;
begin
  Result := inherited ToBytes(value);
end;

function TTrasncoderDate.ToObject(value: TBytes): TDateTime;
begin
  Result := inherited ToObject(value);
end;

{ TTranscoder<T> }

class function TTranscoder.Default<T>: TTranscoder;
var
  Info: PTypeInfo;
begin
  Info := TypeInfo(T);
  Result := nil;
  case Info.Kind of
    tkEnumeration:
      if (Info.Name = 'Boolean') then begin
        Result := TTrasncoderBool.Create;
      end;
    tkInteger:
      Result := TTrasncoderInt32.Create;
    tkFloat:
      Result := TTrasncoderDouble.Create;
    tkLString:
      Result := TTrasncoderAnsiString.Create;
    tkUString:
      Result := TTrasncoderString.Create;
   end;
end;

end.
