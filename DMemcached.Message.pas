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

unit DMemcached.Message;

interface

uses
  System.Classes,
  System.SysUtils,
  DMemcached.Trasncoder;

type
  opMagic = (Request = $80, Response = $81);

  opCodes = (opGet = $00, opSet = $01, opAdd = $02, opReplace = $03, opDelete = $04, opIncrement = $05, opDecrement = $06, opQuit = $07, opFlush = $08, opGetQ = $09, opNoop = $0A, opVersion = $0B , opGetK = $0C, opGetKQ = $0D, opAppend = $0E, opPrepend = $0F, opStat = $10, opSetQ = $11, opAddQ = $12, opReplaceQ = $13, opDeleteQ = $14, opIncrementQ = $15, opDecrementQ = $16, opQuitQ = $17, opFlushQ = $18, opAppendQ = $19, opPrependQ = $1A);

  respStatus = (NoError = $00, KeyNotFound = $01, KeyExists = $02, ValueTooLarge = $03, InvalidArguments = $04, ItemNotStored = $05, NonNumericValue = $06);

  TMemcaheHeader = class
  strict private
    FOpcode: opCodes;
    FKeyLength: UInt16;
    FExtraLength: Byte;
    FBodyLength: UInt32;
    FOpaque: TBytes;
    FCAS: UInt64;
  protected
    FMagic: opMagic;
    function Reserved: TBytes; virtual; abstract;
  public
    constructor Create;
    property Magic: opMagic read FMagic;
    property OpCode: opCodes read FOpcode write FOpcode;
    property KeyLength: UInt16 read FKeyLength write FKeyLength;
    property ExtraLength: Byte read FExtraLength write FExtraLength;
    property BodyLength: UInt32 read FBodyLength write FBodyLength;
    property Opaque: TBytes read FOpaque write FOpaque;
    property CAS: UInt64 read FCAS write FCAS;
    function Pack: TBytes;
    procedure Unpack(data: TBytes); virtual;
  end;

  TMemcaheResponseHeader = class(TMemcaheHeader)
  strict private
    FStatus: respStatus;
  protected
    function Reserved: TBytes; override;
  public
    constructor Create;
    property Status: respStatus read FStatus write FStatus;
    procedure Unpack(data: TBytes); override;
  end;

  TMemcaheRequestHeader = class(TMemcaheHeader)
  protected
    function Reserved: TBytes; override;
  public
    constructor Create;
  end;

  TMemcachedBaseMessage<T> = class
  private
    FHeader: TMemcaheHeader;
    FKey: String;
    FTranscoder: ITranscoder<T>;
    FValue: T;
    function KeyBytes: TBytes;
  protected
    function Extra: TBytes; virtual;
    procedure SetExtra(extra : TBytes); virtual;
    function ValueLength: UInt32;
  public
    constructor Create(opcode: opCodes; key: String; transcoder: ITranscoder<T>); overload;  virtual;
    constructor Create(data: TBytes; transcoder: ITranscoder<T>); overload;  virtual;
    property Key: String read FKey write FKey;
    property Value: T read FValue write FValue;
    property Header: TMemcaheHeader read FHeader;
    function Pack: TBytes;
    procedure Unpack(data: TBytes); virtual;
  end;

  TMemcachedSetMessage<T> = class(TMemcachedBaseMessage<T>)
  private
    FFlags: UInt32;
    FExpire: UInt32;
  protected
    function Extra: TBytes; override;
    procedure SetExtra(extra : TBytes); override;
  public
    constructor Create(opcode: opCodes; key: String; value: T;
      flags: UInt32; expire: UInt32; transcoder: ITranscoder<T>);
  end;

  TMemcachedGetMessage<T> = class(TMemcachedBaseMessage<T>)
  public
    constructor Create(opcode: opCodes; key: String; transcoder: ITranscoder<T>); override;
  end;

  TMemcachedResponseMessage<T> = class(TMemcachedBaseMessage<T>)
  public
    constructor Create(responseHeader: TBytes; transcoder: ITranscoder<T>); override;
  end;

implementation

uses
  DMemcached.Util;

const
  headerSize = 24;
  magicOffset = 0;
  opcodOffset = 1;
  keyLengthOffset = 2;
  extraLengthOffset = 4;
  dataTypaOffset = 5;
  reservedOffset = 6;
  bodyLengthOffset = 8;
  opaqueOffset = 12;
  casOffset = 16;

{ TMemcachedBaseMessage }

constructor TMemcachedBaseMessage<T>.Create(opcode: opCodes; key: String;
  transcoder: ITranscoder<T>);
begin
  FHeader := TMemcaheRequestHeader.Create;
  FHeader.OpCode := opcode;
  FKey := key;
  FHeader.KeyLength := Length(key) * SizeOf(Char);
  FTranscoder := transcoder;
end;

constructor TMemcachedBaseMessage<T>.Create(data: TBytes; transcoder: ITranscoder<T>);
begin
  FHeader := TMemcaheRequestHeader.Create;
  Unpack(data);
end;

function TMemcachedBaseMessage<T>.Extra: TBytes;
begin
  SetLength(Result, 0);
end;

function TMemcachedBaseMessage<T>.KeyBytes: TBytes;
begin
  Result := WideBytesOf(FKey);
end;

function TMemcachedBaseMessage<T>.Pack: TBytes;
var
  index: NativeInt;
  extra: TBytes;
  value: TBytes;
  key: TBytes;
begin
  Result := FHeader.Pack;
  SetLength(Result, headerSize + FHeader.BodyLength);
  index := headerSize;

  extra := self.Extra;
  Move(extra[0], Result[index], Length(extra));
  index := index + Length(extra);

  key := KeyBytes;
  Move(key[0], Result[index], Length(key));
  index := index + Length(key);

  value := FTranscoder.ToBytes(FValue);
  Move(value[0], Result[index], Length(value));
end;

procedure TMemcachedBaseMessage<T>.SetExtra(extra: TBytes);
begin

end;

procedure TMemcachedBaseMessage<T>.Unpack(data: TBytes);
var
  index: NativeInt;
begin
  FHeader.Unpack(data);
  if NativeInt(Length(data)) >= NativeInt(headerSize + FHeader.BodyLength) then begin
    index := headerSize;
    if (FHeader.ExtraLength > 0) then begin
      SetExtra(Copy(data, index, FHeader.ExtraLength));
      index := index + FHeader.ExtraLength;
    end;

    if (FHeader.KeyLength > 0) then begin
      FKey := TEncoding.Unicode.GetString(Copy(data, index, FHeader.KeyLength));
      index := index + FHeader.KeyLength;
    end;

    if (FHeader.BodyLength > FHeader.ExtraLength + FHeader.KeyLength) then begin
      FValue := FTranscoder.ToObject(Copy(data, index, FHeader.BodyLength - (FHeader.ExtraLength + FHeader.KeyLength)));
    end;
  end;
end;

function TMemcachedBaseMessage<T>.ValueLength: UInt32;
begin
  Result := FTranscoder.BytesSize(FValue);
end;

{ TMemcaheHeader }

constructor TMemcaheHeader.Create;
begin
  SetLength(FOpaque, 4);
  FCAS := 0;
end;

{ TMemcachedSetMessage<T> }


constructor TMemcachedSetMessage<T>.Create(opcode: opCodes; key: String;
  value: T; flags: UInt32; expire: UInt32; transcoder: ITranscoder<T>);
begin
  inherited Create(opcode, key, transcoder);
  FValue := value;
  FHeader.ExtraLength := 8;
  FFlags := flags;
  FExpire := expire;
  FHeader.BodyLength := FHeader.ExtraLength + FHeader.KeyLength + ValueLength;
end;

function TMemcachedSetMessage<T>.Extra: TBytes;
var
  flagsBytes: TBytes;
  expireBytes: TBytes;
begin
  SetLength(Result, 8);
  flagsBytes := UInt32ToByte(FFlags);
  Move(flagsBytes[0], Result[0], 4);

  expireBytes := UInt32ToByte(FExpire);
  Move(expireBytes[0], Result[4], 4);
end;

procedure TMemcachedSetMessage<T>.SetExtra(extra: TBytes);
begin
  if Length(extra) = 8 then begin
    FFlags := ByteToUInt32(Copy(extra, 0, 4));
    FExpire := ByteToUInt32(Copy(extra, 4, 4));
  end;
end;

function TMemcaheHeader.Pack: TBytes;
var
  emptyValue: NativeInt;
  reserved: TBytes;
begin
  emptyValue := 0;
  SetLength(Result, headerSize);
  Move(Magic, Result[magicOffset], 1);
  Move(Opcode, Result[opcodOffset], 1);
  Move(WordToByte(KeyLength)[0], Result[keyLengthOffset], SizeOf(KeyLength));
  // Extras
  Move(ExtraLength, Result[extraLengthOffset], SizeOf(ExtraLength));
  // DataType
  Move(emptyValue, Result[dataTypaOffset], 1);
  // Reserved
  reserved := self.Reserved;
  Move(reserved[0], Result[reservedOffset], 2);
  // BodyLength
  Move(UInt32ToByte(BodyLength)[0], Result[bodyLengthOffset], SizeOf(BodyLength));
  // Opaque
  Move(Opaque[0], Result[opaqueOffset], 4);
  // CAS
  Move(UInt64ToByte(CAS)[0], Result[casOffset], SizeOf(CAS));
end;


procedure TMemcaheHeader.Unpack(data: TBytes);
begin
  if Length(data) >= headerSize then begin
    FMagic := opMagic(data[magicOffset]);
    Opcode := opCodes(data[opcodOffset]);
    KeyLength := ByteToWord(Copy(data, keyLengthOffset, SizeOf(KeyLength)));
    ExtraLength := data[extraLengthOffset];
    BodyLength := ByteToUInt32(Copy(data, bodyLengthOffset, SizeOf(BodyLength)));
    FOpaque := Copy(data, opaqueOffset, 4);
    CAS := ByteToUInt64(Copy(data, casOffset, SizeOf(CAS)));
  end;
end;

{ TMemcaheRequestHeader }

constructor TMemcaheRequestHeader.Create;
begin
  inherited Create;
  FMagic := Request;
end;

function TMemcaheRequestHeader.Reserved: TBytes;
begin
  SetLength(Result, 2);
end;

{ TMemcaheResponseHeader }

constructor TMemcaheResponseHeader.Create;
begin
  inherited Create;
  FMagic := Response;
end;

function TMemcaheResponseHeader.Reserved: TBytes;
var
  status: TBytes;
begin
  SetLength(Result, 2);
  status := WordToByte(Word(FStatus));
  Move(status[0], Result[0], 2);
end;

procedure TMemcaheResponseHeader.Unpack(data: TBytes);
begin
  inherited Unpack(data);
  FStatus := respStatus(ByteToWord(Copy(data, reservedOffset, 2)));
end;

{ TMemcachedResponseMessage<T> }

constructor TMemcachedResponseMessage<T>.Create(responseHeader: TBytes; transcoder: ITranscoder<T>);
begin
  FHeader := TMemcaheResponseHeader.Create;
  FTranscoder := transcoder;
  FHeader.Unpack(responseHeader);
end;


{ TMemcachedGetMessage<T> }

constructor TMemcachedGetMessage<T>.Create(opcode: opCodes; key: String;
  transcoder: ITranscoder<T>);
begin
  inherited Create(opcode, key, transcoder);
  FValue := value;
  FHeader.ExtraLength := 0;
  FHeader.BodyLength := FHeader.ExtraLength + FHeader.KeyLength + ValueLength;

end;

end.
