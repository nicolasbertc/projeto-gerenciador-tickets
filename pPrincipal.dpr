program pPrincipal;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipal in 'uPrincipal.pas' {frm_Principal},
  uFuncionario in 'uFuncionario.pas' {frm_Funcionario},
  uTickets in 'uTickets.pas' {frm_Tickets};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_Principal, frm_Principal);
  Application.CreateForm(Tfrm_Funcionario, frm_Funcionario);
  Application.CreateForm(Tfrm_Tickets, frm_Tickets);
  Application.Run;
end.
