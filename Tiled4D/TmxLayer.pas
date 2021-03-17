unit TmxLayer;

interface

type
  TTmxLayerType = (ltTileLayer, ltObjectGroup);

  TTmxLayer = class
  private
    FLayerType: TTmxLayerType;
    FName: string;
    FX: Integer;
    FY: Integer;
    FVisible: Boolean;
  public
    constructor Create(const AName: string); virtual;
    property LayerType: TTmxLayerType read FLayerType write FLayerType;
    property Name: string read FName write FName;
    property X: Integer read FX write FX;
    property Y: Integer read FY write FY;
    property Visible: Boolean read FVisible write FVisible;
  end;

implementation

{ TTmxLayer }

constructor TTmxLayer.Create(const AName: string);
begin
  FName := AName;
  FVisible := False;
end;

end.
