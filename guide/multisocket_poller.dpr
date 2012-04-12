program multisocket_poller;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, zeromq;

procedure Run;
var
  Z: IZeroMQ;
  Receiver, Subscriber: IZMQPair;
  Poll: IZMQPoll;
begin
  Z := TZeroMQ.Create;
  Receiver := Z.Start(ZMQ.Pull);
  Receiver.Connect('tcp://localhost:5557');

  Subscriber := Z.Start(ZMQ.Subscriber);
  Subscriber.Connect('tcp://localhost:5556');
  Subscriber.Subscribe('10001 ');

  Poll := Z.Poller;

  Poll.RegisterPair(Receiver, [PollEvent.PollIn],
    procedure(Event: PollEvents)
    var
      S: string;
    begin
      if PollEvent.PollIn in Event then
      begin
        S := Receiver.ReceiveString;
        WriteLn('Receiver ! (', S, ')');
        Sleep(StrToInt(S));
      end;
    end
  );

  Poll.RegisterPair(Subscriber, [PollEvent.PollIn],
    procedure(Event: PollEvents)
    begin
      if PollEvent.PollIn in Event then
        WriteLn('Subscriber ! (', Subscriber.ReceiveString, ')');
    end
  );

  Poll.PollForever;
end;

begin
  try
    Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
