unit TmxLayer;

interface

uses
  Xml.XMLIntf;

type
  TTmxCSVData = array of array of Integer;

  TTmxLayer = class
  private
    FName: string;
    FWidth: Integer;
    FHeight: Integer;
    FVisible: Boolean;
    FData: TTmxCSVData;
  public
    procedure ParseXML(const Node: IXMLNode);
    property Name: string read FName write FName;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Visible: Boolean read FVisible write FVisible;
    property Data: TTmxCSVData read FData write FData;
  end;

implementation

uses
  System.Classes, System.SysUtils;

{ TTmxLayer }

procedure TTmxLayer.ParseXML(const Node: IXMLNode);
var
  ChildNode: IXMLNode;
  List: TStringList;
  TokenList: TStringList;
  Data: TTmxCSVData;
  X, Y: Integer;
  Gid: string;
begin
  FName := Node.Attributes['name'];
  FWidth := Node.Attributes['width'];
  FHeight := Node.Attributes['height'];

  FVisible := True;
  if Node.HasAttribute('visible') then
    FVisible := Node.Attributes['visible'];

  ChildNode := Node.ChildNodes['data'];
  SetLength(Data, FWidth, FHeight);
  FData := Data;

  List := TStringList.Create;
  TokenList := TStringList.Create;
  try
    List.Text := ChildNode.Text;
    List.Delete(0);

    TokenList.Delimiter := ',';
    TokenList.StrictDelimiter := True;
    for Y := 0 to FHeight - 1 do
    begin
      TokenList.DelimitedText := List[Y];
      for X := 0 to FWidth - 1 do
      begin
        Gid := TokenList[X];
        Data[Y, X] := StrToInt(Gid);
      end;
    end;
  finally
    TokenList.Free;
    List.Free;
  end;
end;

end.
