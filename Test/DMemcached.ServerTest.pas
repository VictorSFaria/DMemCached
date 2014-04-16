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

unit DMemcached.ServerTest;

interface

uses
  DUnitX.TestFramework, DMemcached.Memcached;

type
  {$M+}
  [TestFixture()]
  TConnectionTest = class
  private
    FClient: IMemCacheClient<String>;
  public
    constructor Create;
    [Test]
    procedure TestAdd;
    [Test]
    procedure TestDelete;
    [Test]
    procedure TestAddFail;
    [Test]
    procedure TestGet;
    [Test]
    procedure TestGetSet;
    [Test]
    procedure TestReplace;
    [Test]
    procedure TestVersion;
    [Test]
    procedure TestFlush;
  end;

implementation

uses
  DMemcached.Trasncoder, SysUtils, CLasses;

{ TConnectionTest }

constructor TConnectionTest.Create;
begin
  FClient := TMemcachedClient<String>.Create('localhost', 11211);
end;

procedure TConnectionTest.TestAdd;
var
  value: String;
begin
  FClient.Delete('key_add');
  FClient.Add('key_add', 'value 1');
  value :=  FClient.Get('key_add');
  Assert.AreEqual('value 1', value);
end;

procedure TConnectionTest.TestAddFail;
begin
  FClient.Delete('key_add_fail');
  Assert.IsTrue(FClient.Add('key_add_fail', 'value 1'));
  Assert.IsFalse(FClient.Add('key_add_fail', 'value 1'));
end;

procedure TConnectionTest.TestDelete;
begin
  Assert.IsFalse(FClient.Delete('key_delete'));
  FClient.Store('key_delete', 'value 1');
  Assert.IsTrue(FClient.Delete('key_delete'));
end;

procedure TConnectionTest.TestFlush;
begin
  FClient.Flush;
end;

procedure TConnectionTest.TestGet;
begin
  FClient.Get('Minha_Primeira_Chave');
end;

procedure TConnectionTest.TestGetSet;
var
  value: String;
begin
  FClient.Store('key_set', 'value 1');
  value :=  FClient.Get('key_set');
  Assert.AreEqual('value 1', value);
end;

procedure TConnectionTest.TestReplace;
var
  value: String;
begin
  FClient.Store('key_replace', 'value 1');
  value :=  FClient.Get('key_replace');
  Assert.AreEqual('value 1', value);

  FClient.Replace('key_replace', 'value 2');
  value :=  FClient.Get('key_replace');
  Assert.AreEqual('value 2', value);
end;

procedure TConnectionTest.TestVersion;
begin
  Assert.IsNotEmpty(FClient.Version);
end;

initialization
  TDUnitX.RegisterTestFixture(TConnectionTest);

end.
