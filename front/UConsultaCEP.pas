unit UConsultaCEP;

interface

uses
  REST.Types, REST.Client, REST.Authenticator.Basic, Data.Bind.Components, Data.Bind.ObjectScope,
  System.SysUtils, System.JSON,
  UCEP;

type
  TRetornoCEP = class
  private
    FCEP: TCEP;
    FSucesso: Boolean;
    FMensagem: string;
    procedure SetCEP(const ACEP: TCEP);
    function GetCEP: TCEP;
    procedure SetSucesso(const ASucesso: Boolean);
    function GetSucesso: Boolean;
    procedure SetMensagem(const AMensagem: string);
    function GetMensagem: string;
  public
    constructor Create();
    property CEP: TCEP read GetCEP write SetCEP;
    property Sucesso: Boolean read GetSucesso write SetSucesso;
    property Mensagem: string read GetMensagem write SetMensagem;
  end;

  TConsultaCEP = class
  private

  public
    function Consultar(Cep: string): TRetornoCEP;
  end;

implementation



{ TConsultaCEP }

function TConsultaCEP.Consultar(Cep: string): TRetornoCEP;
var
  Retorno: TRetornoCEP;
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  Response: TJSONObject;
begin
  Retorno:= TRetornoCEP.Create;
  try
    try
      RESTClient:= TRESTClient.Create('https://localhost:32768/api/');

      RESTResponse:= TRESTResponse.Create(nil);

      RESTRequest:= TRESTRequest.Create(nil);
      RESTRequest.Client:= RESTClient;
      RESTRequest.Response:= RESTResponse;
      RESTRequest.Timeout:= 5 * 1000;

      RESTRequest.ResourceSuffix := 'cep/consultar?cep=' + Cep;
      RESTRequest.Method := rmGET;

      RESTRequest.Execute;

      Response:= (RESTResponse.JSONValue as System.JSON.TJSONObject);

      if RESTRequest.Response.Status.SuccessOK_200 then
      begin
        Retorno.Sucesso:= True;
        Retorno.Mensagem:= Response.Values['message'].Value;

        Response:= (Response.Values['data'] as System.JSON.TJSONObject);

        Retorno.CEP:= TCEP.Create;
        Retorno.CEP.CEP:= Response.Values['cep'].Value;
        Retorno.CEP.UF:= Response.Values['uf'].Value;
        Retorno.CEP.Cidade:= Response.Values['cidade'].Value;
        Retorno.CEP.Bairro:= Response.Values['bairro'].Value;
        Retorno.CEP.Logradouro:= Response.Values['logradouro'].Value;
      end
      else
      begin
        Retorno.Sucesso:= True;
        Retorno.Mensagem:= Response.Values['message'].Value;
        Retorno.CEP:= TCEP.Create;
      end;

      Result:= Retorno;
    except
      on E: Exception do
      begin
        Retorno.Sucesso:= False;

        if E.Message = 'REST request failed: Error sending data: (12002) O tempo limite da opera��o foi atingido' then
          Retorno.Mensagem:= 'Servi�o temporariamente indispon�vel. Por favor tente mais tarde.'
        else
          Retorno.Mensagem:= E.Message;
        Result:= Retorno;
      end;
    end;
  finally
    RESTResponse.Free;
    RESTRequest.Free;
    RESTClient.Free;
  end;
end;

{ TRetornoCEP }

constructor TRetornoCEP.Create;
begin

end;

function TRetornoCEP.GetCEP: TCEP;
begin
  Result:= FCEP;
end;

function TRetornoCEP.GetMensagem: string;
begin
  Result:= FMensagem;
end;

function TRetornoCEP.GetSucesso: Boolean;
begin
  Result:= FSucesso;
end;

procedure TRetornoCEP.SetCEP(const ACEP: TCEP);
begin
  FCEP:= ACEP;
end;

procedure TRetornoCEP.SetMensagem(const AMensagem: string);
begin
  FMensagem:= AMensagem;
end;

procedure TRetornoCEP.SetSucesso(const ASucesso: Boolean);
begin
 FSucesso:= ASucesso;
end;

end.
