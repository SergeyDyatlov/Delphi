unit TmxObjectGroup;

interface

uses
  TmxLayer, System.Generics.Collections;

type
  TTmxObject = class
  private
    FId: Integer;
    FName: string;
    FObjectType: string;
    FX: Integer;
    FY: Integer;
    FWidth: Integer;
    FHeight: Integer;
  public
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property ObjectType: string read FObjectType write FObjectType;
    property X: Integer read FX write FX;
    property Y: Integer read FY write FY;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
  end;

  TTmxObjectGroup = class(TTmxLayer)
  private
    FObjects: TObjectList<TTmxObject>;
    FName: string;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    property Name: string read FName write FName;
    property Objects: TObjectList<TTmxObject> read FObjects;
  end;

implementation

{ TTmxObjectGroup }

constructor TTmxObjectGroup.Create(const AName: string);
begin
  inherited;
  LayerType := ltObjectGroup;
  FObjects := TObjectList<TTmxObject>.Create(True);
end;

destructor TTmxObjectGroup.Destroy;
begin
  FObjects.Free;
  inherited;
end;

end.
