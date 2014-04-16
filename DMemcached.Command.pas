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

unit DMemcached.Command;

interface

uses
  IdTCPClient, DMemcached.Message, DMemcached.Trasncoder;

type
  TCommand<T> = class
  public
    class function ExecuteCommand(FTcpConnection: TIdTCPClient; baseMessage: TMemcachedBaseMessage<T>;
      transcoder: ITranscoder<T>): TMemcachedBaseMessage<T>;
  end;

implementation

uses
  SysUtils, IdGlobal;

{ TCommand<T> }

class function TCommand<T>.ExecuteCommand(FTcpConnection: TIdTCPClient;
  baseMessage: TMemcachedBaseMessage<T>; transcoder: ITranscoder<T>): TMemcachedBaseMessage<T>;
var
  objRequest: TBytes;
  objResponse: TBytes;
begin
  if (FTcpConnection.Connected) then begin
    objRequest := baseMessage.Pack;
    FTcpConnection.Socket.Write(TIdBytes(objRequest), Length(objRequest));

    SetLength(objResponse, 0);

    FTcpConnection.Socket.ReadBytes(TIdBytes(objResponse), 24);
    Result := TMemcachedResponseMessage<T>.Create(objResponse, transcoder).Create;
    if (Result.Header.BodyLength > 0) then begin
      FTcpConnection.Socket.ReadBytes(TIdBytes(objResponse), Result.Header.BodyLength, True);
      Result.Unpack(objResponse);
    end;


    case (Result.Header as TMemcaheResponseHeader).Status of
      respStatus.ValueTooLarge:
        raise Exception.Create('Value Too Large');
      respStatus.InvalidArguments:
        raise Exception.Create('Invalid Arguments');
      respStatus.ItemNotStored:
        raise Exception.Create('Item Not Stored');
      respStatus.NonNumericValue:
        raise Exception.Create('Incr/Decr on non-numeric value');
    end;
  end
  else begin
    raise Exception.Create('Not Connected');
  end;
end;

end.
