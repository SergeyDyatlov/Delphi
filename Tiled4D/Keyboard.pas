unit Keyboard;

interface

uses
  Winapi.Windows;

function IsKeyDown(KeyCode: Integer): Boolean;

implementation

function IsKeyDown(KeyCode: Integer): Boolean;
begin
  Result := GetAsyncKeyState(KeyCode) <> 0;
end;

end.
