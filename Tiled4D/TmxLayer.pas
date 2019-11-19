unit TmxLayer;

interface

uses
  Xml.XMLIntf;

type
  TTmxLayer = class
  private
    FName: string;
    FVisible: Boolean;
  public
    property Name: string read FName write FName;
    property Visible: Boolean read FVisible write FVisible;
  end;

implementation

end.
