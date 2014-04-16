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

unit DMemcached.MemCached;

interface

uses
  IdTCPClient, System.Classes, System.SysUtils, DMemcached.Trasncoder, DMemcached.Message;

type
  IMemCacheClient<T> = interface
    function Add(key: String; value: T; expire: UInt32 = 0; flags: UInt32 = 0): Boolean;
    function Store(key: String; value: T; expire: UInt32 = 0; flags: UInt32 = 0): Boolean;
    function Replace(key: String; value: T; expire: UInt32 = 0; flags: UInt32 = 0): Boolean;
    function Get(key: String): T;
    function Delete(key: String): Boolean;
    function Version: String;
    procedure Flush;
  end;


  TMemcachedClient<T> = class(TInterfacedObject, IMemCacheClient<T>)
  private
    FTcpConnection: TIdTCPClient;
    FTrascoder: ITranscoder<T>;
    function ExecuteCommand(baseMessage: TMemcachedBaseMessage<T>): TMemcachedBaseMessage<T>;
  public
    constructor Create(host: String; port: Integer; trascoder: ITranscoder<T> = nil);
    destructor Destroy; override;
    function Add(key: String; value: T; expire: UInt32 = 0; flags: UInt32 = 0): Boolean;
    function Delete(key: String): Boolean;
    function Store(key: String; value: T; expire: UInt32 = 0; flags: UInt32 = 0): Boolean;
    function Replace(key: String; value: T; expire: UInt32 = 0; flags: UInt32 = 0): Boolean;
    function Get(key: String): T;
    function Version: String;
    procedure Flush;
  end;


implementation

uses
  IdGlobal, DMemcached.Command;

{ TMemcached }


function TMemcachedClient<T>.Add(key: String; value: T; expire: UInt32 = 0; flags: UInt32 = 0): Boolean;
var
  objResponse: TMemcachedBaseMessage<T>;
begin
  objResponse := TCommand<T>.ExecuteCommand(FTcpConnection,
    TMemcachedSetMessage<T>.Create(opAdd, key, value, flags, expire, FTrascoder),
    FTrascoder);
  Result := ((objResponse.Header as TMemcaheResponseHeader).Status = NoError) and (objResponse.Header.CAS <> 0);
end;

constructor TMemcachedClient<T>.Create(host: String; port: Integer; trascoder: ITranscoder<T>);
var
  defaultTrasncoder: TTranscoder;
begin
  if trascoder = nil then begin
    defaultTrasncoder := TTranscoder.Default<T>;
    if not Assigned(defaultTrasncoder) then begin
      raise Exception.Create('Invalid Data Type.');
    end;
    FTrascoder :=  defaultTrasncoder as ITranscoder<T>;
  end
  else begin
    FTrascoder := trascoder;
  end;

  FTcpConnection := TIdTCPClient.Create(nil);
  FTcpConnection.Host := host;
  FTcpConnection.Port := port;
  FTcpConnection.Connect;
end;


function TMemcachedClient<T>.Delete(key: String): Boolean;
var
  objResponse: TMemcachedBaseMessage<T>;
begin
  objResponse := ExecuteCommand(TMemcachedGetMessage<T>.Create(opDelete, key, FTrascoder));
  Result := (objResponse.Header as TMemcaheResponseHeader).Status = NoError;
end;

destructor TMemcachedClient<T>.Destroy;
begin
  FTcpConnection.Disconnect;
  FTcpConnection.Free;
  inherited;
end;

function TMemcachedClient<T>.ExecuteCommand(
  baseMessage: TMemcachedBaseMessage<T>): TMemcachedBaseMessage<T>;
begin
  Result := TCommand<T>.ExecuteCommand(FTcpConnection, baseMessage,
    FTrascoder);
end;

procedure TMemcachedClient<T>.Flush;
var
  objResponse: TMemcachedBaseMessage<T>;
begin
  objResponse := ExecuteCommand(TMemcachedGetMessage<T>.Create(opFlush, '', FTrascoder));
end;

function TMemcachedClient<T>.Get(key: String): T;
var
  objResponse: TMemcachedBaseMessage<T>;
begin
  objResponse := ExecuteCommand(TMemcachedGetMessage<T>.Create(opGet, key, FTrascoder));
  Result := objResponse.Value;
end;

function TMemcachedClient<T>.Replace(key: String; value: T; expire,
  flags: UInt32): Boolean;
var
  objResponse: TMemcachedBaseMessage<T>;
begin
  objResponse := ExecuteCommand(TMemcachedSetMessage<T>.Create(opReplace, key, value, flags, expire, FTrascoder));
  Result := ((objResponse.Header as TMemcaheResponseHeader).Status = NoError) and (objResponse.Header.CAS <> 0);
end;

function TMemcachedClient<T>.Store(key: String; value: T; expire,
  flags: UInt32): Boolean;
var
  objResponse: TMemcachedBaseMessage<T>;
begin
  objResponse := ExecuteCommand(TMemcachedSetMessage<T>.Create(opSet, key, value, flags, expire, FTrascoder));
  Result := ((objResponse.Header as TMemcaheResponseHeader).Status = NoError) and (objResponse.Header.CAS <> 0);
end;

function TMemcachedClient<T>.Version: String;
var
  objResponse: TMemcachedBaseMessage<AnsiString>;
begin
  objResponse := TCommand<AnsiString>.ExecuteCommand(FTcpConnection,
    TMemcachedGetMessage<AnsiString>.Create(opVersion, '', TTrasncoderAnsiString.Create),
    TTrasncoderAnsiString.Create);

  Result := objResponse.Value;
end;

end.
