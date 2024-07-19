unit BreadthFirstSearch;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections,
  System.Generics.Defaults;

type
  TNodeEvent<T> = procedure(Sender: TObject; const Node: T) of object;

  TBreadthFirstSearch<T> = class
  private
    FComparer: IEqualityComparer<T>;
    FVisited: TDictionary<T, T>;
    FOnNodeDetected: TNodeEvent<T>;
    FOnNodeVisited: TNodeEvent<T>;
    function BuildPath(StartNode, EndNode: T): TArray<T>;
  protected
    function GetNeighbors(Node: T): TArray<T>; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    function Search(StartNode, EndNode: T): TArray<T>;
    property Visited: TDictionary<T, T> read FVisited write FVisited;
    property OnNodeDetected: TNodeEvent<T> read FOnNodeDetected write FOnNodeDetected;
    property OnNodeVisited: TNodeEvent<T> read FOnNodeVisited write FOnNodeVisited;
  end;

implementation

{ TBreadthFirstSearch }

function TBreadthFirstSearch<T>.BuildPath(StartNode, EndNode: T)
  : TArray<T>;
var
  Path: TList<T>;
  Current: T;
begin
  Path := TList<T>.Create;
  try
    Current := EndNode;
    while not FComparer.Equals(Current, StartNode) do
    begin
      Path.Insert(0, Current);

      if not FVisited.TryGetValue(Current, Current) then
        Exit(Path.ToArray);
    end;
    Path.Insert(0, StartNode);
    Result := Path.ToArray;
  finally
    Path.Free;
  end;
end;

constructor TBreadthFirstSearch<T>.Create;
begin
  FComparer := TEqualityComparer<T>.Default;
  FVisited := TDictionary<T, T>.Create;
end;

destructor TBreadthFirstSearch<T>.Destroy;
begin
  FVisited.Free;
  inherited;
end;

function TBreadthFirstSearch<T>.Search(StartNode, EndNode: T)
  : TArray<T>;
var
  Queue: TQueue<T>;
  Current, Next: T;
  Neighbors: TArray<T>;
begin
  FVisited.Clear;
  Queue := TQueue<T>.Create;
  try
    Queue.Enqueue(StartNode);
    FVisited.Add(StartNode, Default(T));

    while Queue.Count > 0 do
    begin
      Current := Queue.Dequeue;

      if Assigned(FOnNodeVisited) then
        FOnNodeVisited(Self, Current);

      if FComparer.Equals(Current, EndNode) then
        Break;

      Neighbors := GetNeighbors(Current);
      for Next in Neighbors do
      begin
        if not FVisited.ContainsKey(Next) then
        begin
          Queue.Enqueue(Next);
          FVisited.Add(Next, Current);

          if Assigned(FOnNodeDetected) then
            FOnNodeDetected(Self, Next);
        end;
      end;
    end;

    Result := BuildPath(StartNode, EndNode);
  finally
    Queue.Free;
  end;
end;

end.
