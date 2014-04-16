program DMemCached;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DMemcached.MemCached in 'DMemcached.MemCached.pas',
  DMemcached.Command in 'DMemcached.Command.pas',
  DMemcached.Trasncoder in 'DMemcached.Trasncoder.pas',
  DMemcached.Message in 'DMemcached.Message.pas',
  DUnitX.CommandLine in '..\DUnitX\DUnitX.CommandLine.pas',
  DUnitX.DUnitCompatibility in '..\DUnitX\DUnitX.DUnitCompatibility.pas',
  DUnitX.FixtureResult in '..\DUnitX\DUnitX.FixtureResult.pas',
  DUnitX.IoC in '..\DUnitX\DUnitX.IoC.pas',
  DUnitX.Loggers.Console in '..\DUnitX\DUnitX.Loggers.Console.pas',
  DUnitX.Loggers.Text in '..\DUnitX\DUnitX.Loggers.Text.pas',
  DUnitX.Loggers.XML.NUnit in '..\DUnitX\DUnitX.Loggers.XML.NUnit.pas',
  DUnitX.RunResults in '..\DUnitX\DUnitX.RunResults.pas',
  DUnitX.Test in '..\DUnitX\DUnitX.Test.pas',
  DUnitX.TestFixture in '..\DUnitX\DUnitX.TestFixture.pas',
  DUnitX.TestFramework in '..\DUnitX\DUnitX.TestFramework.pas',
  DUnitX.TestResult in '..\DUnitX\DUnitX.TestResult.pas',
  DUnitX.TestRunner in '..\DUnitX\DUnitX.TestRunner.pas',
  DUnitX.Utils in '..\DUnitX\DUnitX.Utils.pas',
  DUnitX.Utils.XML in '..\DUnitX\DUnitX.Utils.XML.pas',
  DUnitX.WeakReference in '..\DUnitX\DUnitX.WeakReference.pas',
  DUnitX.Windows.Console in '..\DUnitX\DUnitX.Windows.Console.pas',
  DUnitX.Generics in '..\DUnitX\DUnitX.Generics.pas',
  DUnitX.InternalInterfaces in '..\DUnitX\DUnitX.InternalInterfaces.pas',
  DUnitX.MemoryLeakMonitor.Default in '..\DUnitX\DUnitX.MemoryLeakMonitor.Default.pas',
  DUnitX.ConsoleWriter.Base in '..\DUnitX\DUnitX.ConsoleWriter.Base.pas',
  DUnitX.Loggers.Null in '..\DUnitX\DUnitX.Loggers.Null.pas',
  DMemcached.Test.Transcoder in 'Test\DMemcached.Test.Transcoder.pas',
  DMemcached.Util in 'DMemcached.Util.pas',
  DMemcached.ServerTest in 'Test\DMemcached.ServerTest.pas',
  DUnitX.Extensibility in '..\DUnitX\DUnitX.Extensibility.pas',
  DUnitX.Extensibility.PluginManager in '..\DUnitX\DUnitX.Extensibility.PluginManager.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
begin
  try
    runner := TDUnitX.CreateRunner;
    runner.UseRTTI := True;
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);

    results := runner.Execute;

    System.Write('Done.. press <Enter> key to quit.');
    System.Readln;
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
