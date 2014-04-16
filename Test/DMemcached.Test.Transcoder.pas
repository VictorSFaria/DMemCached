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

unit DMemcached.Test.Transcoder;

interface

uses
  DUnitX.TestFramework;

type
  {$M+}
  [TestFixture()]
  TTranscoderTest = class
  public
    [Test]
    procedure TestAnsiString;
    [Test]
    procedure TestBoolean;
    [Test]
    procedure TestString;
    [Test]
    procedure TestInt32;
    [Test]
    procedure TestDouble;
    [Test]
    procedure TestDateTime;
    [Test]
    procedure TestDefault;
  end;

implementation

uses
  DMemcached.Trasncoder, SysUtils;

{ TTranscoderTest }

procedure TTranscoderTest.TestAnsiString;
var
  transcoder: ITranscoder<AnsiString>;
begin
  transcoder := TTrasncoderAnsiString.Create;

  Assert.AreEqual<AnsiString>('Hello', transcoder.ToObject(transcoder.ToBytes('Hello')));
  Assert.AreEqual<Word>(5, transcoder.BytesSize('Hello'));
end;

procedure TTranscoderTest.TestBoolean;
var
  transcoder: ITranscoder<Boolean>;
begin
  transcoder := TTrasncoderBool.Create;

  Assert.AreEqual<Boolean>(True, transcoder.ToObject(transcoder.ToBytes(True)));
  Assert.AreEqual<Boolean>(False, transcoder.ToObject(transcoder.ToBytes(False)));
  Assert.AreEqual<Word>(1, transcoder.BytesSize(True));
end;

procedure TTranscoderTest.TestDateTime;
var
  transcoder: ITranscoder<TDateTime>;
  data: TDateTime;
begin
  transcoder := TTrasncoderDate.Create;
  data := Now();
  Assert.AreEqual<TDateTime>(data, transcoder.ToObject(transcoder.ToBytes(data)));
  Assert.AreEqual<Word>(8, transcoder.BytesSize(1));
end;

procedure TTranscoderTest.TestDefault;
begin
  Assert.IsTrue(TTranscoder.Default<AnsiString>() is TTrasncoderAnsiString);
  Assert.IsTrue(TTranscoder.Default<String>() is TTrasncoderString);
  Assert.IsTrue(TTranscoder.Default<Double>() is TTrasncoderDouble);
  Assert.IsTrue(TTranscoder.Default<Boolean>() is TTrasncoderBool);
end;

procedure TTranscoderTest.TestDouble;
var
  transcoder: ITranscoder<Double>;
begin
  transcoder := TTrasncoderDouble.Create;

  Assert.AreEqual<Double>(526.2563, transcoder.ToObject(transcoder.ToBytes(526.2563)));
  Assert.AreEqual<Double>(-526.2563, transcoder.ToObject(transcoder.ToBytes(-526.2563)));
  Assert.AreEqual<Word>(8, transcoder.BytesSize(1));
end;

procedure TTranscoderTest.TestInt32;
var
  transcoder: ITranscoder<Int32>;
begin
  transcoder := TTrasncoderInt32.Create;
  Assert.AreEqual<Int32>(Int32.MaxValue, transcoder.ToObject(transcoder.ToBytes(Int32.MaxValue)));
  Assert.AreEqual<Int32>(Int32.MinValue, transcoder.ToObject(transcoder.ToBytes(Int32.MinValue)));
  Assert.AreEqual<Word>(4, transcoder.BytesSize(1));
end;

procedure TTranscoderTest.TestString;
var
  transcoder: ITranscoder<String>;
begin
  transcoder := TTrasncoderString.Create;

  Assert.AreEqual<String>('Hello', transcoder.ToObject(transcoder.ToBytes('Hello')));
  Assert.AreEqual<Word>(10, transcoder.BytesSize('Hello'));
end;

initialization
  TDUnitX.RegisterTestFixture(TTranscoderTest);

end.
