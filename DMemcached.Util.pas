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

unit DMemcached.Util;

interface

uses
  SysUtils;


function UInt64ToByte(value: UInt64): TBytes;

function ByteToUInt64(value: TBytes): UInt64;

function UInt32ToByte(value: UInt32): TBytes;

function ByteToUInt32(value: TBytes): UInt32;

function WordToByte(value: Word): TBytes;

function ByteToWord(value: TBytes): Word;


implementation

function WordToByte(value: Word): TBytes;
begin
  SetLength(Result, 2);
  Result[0] := (value shr 8);
  Result[1] := (value);
end;

function ByteToWord(value: TBytes): Word;
begin
  Result := (value[0] shl 8) or value[1];
end;

function UInt32ToByte(value: UInt32): TBytes;
begin
  SetLength(Result, 4);
  Result[0] := (value shr 24);
  Result[1] := (value shr 16);
  Result[2] := (value shr 8);
  Result[3] := (value);
end;

function ByteToUInt32(value: TBytes): UInt32;
begin
  Result := (value[0] shl 24) or ( value[1] shl 16) or (value[2] shl 8) or value[3];
end;


function UInt64ToByte(value: UInt64): TBytes;
begin
  SetLength(Result, 8);
  Result[0] := (value shr 56);
  Result[1] := (value shr 48);
  Result[2] := (value shr 40);
  Result[3] := (value shr 32);
  Result[4] := (value shr 24);
  Result[5] := (value shr 16);
  Result[6] := (value shr 8);
  Result[7] := (value);
end;

function ByteToUInt64(value: TBytes): UInt64;
begin
  Result :=  (Int64(value[0]) shl 56) or (Int64(value[1]) shl 48) or (Int64(value[2]) shl 40) or
  (Int64(value[3]) shl 32) or (value[4] shl 24) or (value[5] shl 16) or ( value[6] shl 8) or value[7];
end;


end.
