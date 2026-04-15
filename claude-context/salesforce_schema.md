# Salesforce — Schema, Convenções e Regras de Interpretação

## Objeto: M_A_Project__c (M&A Project)

### Campos principais
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `Name` | M&A Project Name | string | Codinome do projeto (ex: Atlas, Aurora) |
| `Client__c` | Client | reference → Account | Empresa cliente |
| `Status__c` | Status | picklist | Ativo, Estaleiro, Standby, Interrompido, Fechado |
| `Type__c` | Type | picklist | Sellside, SSide Fundo, Buyside, Valuation, Broker |
| `Current_Stage__c` | Current Stage | picklist | Preparação de Materiais → Market Sounding → Negociação de NBO → Diligência → Negociação de Contratos → Fechamento |
| `Estimated_Fee__c` | M&A Fee Bruto (R$mm) | currency | Fee bruto estimado |
| `M_A_Adjusted_Fee_R_mm__c` | M&A Adjusted Fee (R$mm) | double | Fee ajustado — fórmula: `min(fee_bruto, 8)`, com 50% para Broker sem NBO recebida |
| `Fee_ponderado__c` | Fee ponderado | currency | Calculado (fee × probabilidade) |
| `Prob_Success__c` | Prob Success | percent | Probabilidade de sucesso |
| `S_cio_Execu__c` | Sócio Execução | reference → User | Sócio responsável pela execução |
| `Celula_del__c` | Celula | reference → Contact | Célula responsável |
| `Originator__c` | Originator | reference → User | Quem originou |
| `Associate__c` | Associate | reference → User | Associate do projeto |
| `Analyst__c` | Analyst | reference → User | Analista do projeto |

### Datas do pipeline
| Campo API | Label | Notas |
|---|---|---|
| `Kick_Off__c` | Kick-Off | Início do mandato |
| `Mkt_Sounding_Start__c` | Mkt Sounding Start | Início do market sounding |
| `NBO_Received__c` | NBO Received | NBO recebida |
| `NBO_Signed__c` | NBO Signed | NBO assinada — **define entrada no backlog pós-NBO** |
| `Contracts_Received__c` | Contracts Received | Contratos recebidos |
| `Signing_Date__c` | Signing Date | Assinatura |
| `Closing_Date__c` | Closing Date | Fechamento |

### Campos financeiros do cliente
| Campo API | Label |
|---|---|
| `Revenue_R_mm__c` | Revenue (R$mm) |
| `EBITDA_R_mm__c` | EBITDA (R$mm) |
| `Valuation_Expectation__c` | Valuation Expectation |

### Campos adicionais
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `Data_de_ativacao_do_fee__c` | Data de ativação do fee | date | Usado para meta "fee ativado". Inclui projetos e brokers |
| `Estimated_NBO_Signature__c` | Estimated NBO Signature | date | Data estimada de assinatura de NBO |
| `Estimated_Closing__c` | Estimated Closing | date | Data estimada de closing |
| `Estimated_Signing__c` | Estimated Signing | date | Data estimada de signing do deal (não confundir com NBO signature) |

### Histórico (M_A_Project__History)
- Campos com tracking: Status, Stage, Fee, Prob, Sócio, Analyst, Associate, Client, e outros
- Usar para reconstruir estados passados quando necessário

### Critério "pós-NBO" (backlog ativo)
- `NBO_Signed__c IS NOT NULL` **e** `Status__c = 'Ativo'`

### Status e significado
| Status | Significado |
|---|---|
| Ativo | Projeto em execução |
| Estaleiro | Fase de validação pós-mandato antes de ir a mercado (números, tese, valuation) |
| Standby | Projeto on hold (falta de tração, números piorando, etc.) |
| Interrompido | Projeto cancelado |
| Fechado | Deal concluído |

### Fluxo de etapas (Current_Stage__c)
Preparação de Materiais → Market Sounding → Negociação de NBO → Diligência → Negociação de Contratos → Fechamento

### Referências (relationship fields)
- `Client__r.Name` → nome da Account (empresa cliente)
- `S_cio_Execu__r.Name` → nome do sócio de execução
- Sempre remover `attributes` dos dicts retornados pelo SF ao salvar snapshots

---

## Objeto: Recebimentos__c (Recebimentos futuros)

### Campos
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `Name` | Descrição da parcela | string (80) | Texto livre descritivo |
| `Data_estimada_de_recebimento__c` | Data estimada de recebimento | date | Data prevista |
| `Valor_bruto_R_mm__c` | Valor bruto (R$mm) | currency | Valor da parcela |
| `Probabilidade_de_recebimento__c` | Probabilidade de recebimento | percent | **Não usar** — nunca funcionou |
| `Recebimento_ponderado_R_mm__c` | Recebimento ponderado (R$mm) | currency | **Não usar** — depende do campo acima |
| `M_A_Project__c` | M&A Project | reference → M_A_Project__c | Projeto M&A de origem |
| `DCM_Project__c` | DCM Project | reference → DCM_Project__c | Projeto DCM de origem |
| `Tipo__c` | Tipo | picklist | `Fixo` / `Contingente provável` / `Contingente incerto` | Fixo = parcelamento certo. Provável = earn-out manutenção. Incerto = earn-out crescimento agressivo |
| `Status__c` | Status | picklist | `Pendente` / `Recebido` / `Cancelado` | Atrasado = inferido (Pendente + data passada) |

### Contexto de negócio
- Registra **parcelas futuras de fee já contratado** de deals fechados
- Fluxo: Recebimento Pendente → parcela paga → cria Faturamento → marca como "Recebido"
- Relação Recebimento ↔ Faturamento é N:N (sem lookup), reconciliação pelo Status

### Lógica de projeção (para relatório de metas)
- **Pesos por Tipo**: Fixo = 100%, Contingente provável = 75%, Contingente incerto = 25%
- Projeção = SUM(Valor_bruto × peso) WHERE Status = 'Pendente' AND Data no período
- Entra na meta 1 (faturamento total) e meta 2 (fee de sucesso)

### Objeto legado
| Objeto | Notas |
|---|---|
| `Recebimento_futuro__c` | Versão anterior (sem DCM_Project) |

---

## Objeto: Faturamento_M_A__c (Faturamento M&A)
| Campo API | Label | Tipo |
|---|---|---|
| `Valor_do_servi_o__c` | Valor do serviço | currency (R$) |
| `Data_de_emissao__c` | Data de emissão | date |
| `Categoria__c` | Categoria | string |
| `M_A_Project__c` | M&A Project | reference |
- Categorias: "1.1.01 Assessoria Financeira - Fee de Sucesso", "1.1.02 Assessoria Financeira - Retainer"

## Objeto: Faturamento_DCM__c (Faturamento DCM)
| Campo API | Label | Tipo |
|---|---|---|
| `Valor_do_servi_o__c` | Valor do serviço | currency (R$) |
| `Data_de_emiss_o__c` | Data de emissão | date |
| `Categoria__c` | Categoria | string |
| `DCM_Project__c` | DCM Project | reference |
- **Atenção:** campo de data com acento diferente do M&A (`emiss_o` vs `emissao`)

## Objeto: Opportunity (para fee mandatado e atividade de funil)
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `M_A_Adjusted_Fee__c` | M&A Adjusted Fee (R$mm) | double | |
| `CloseDate` | Close Date | date | |
| `StageName` | Stage | picklist | |
| `Service__c` | Service | picklist (M&A, DCM) | |
| `Type` | Opportunity Type | picklist (Inbound, Outbound) | Fonte do lead |
| `Opportunity_Originator__r.Name` | Originating partner | reference | |
| `Qualification_Meeting_Date__c` | Qualification Meeting Date | date | Data da QM |
| `Tipo_de_QM__c` | Tipo de QM | picklist (Lead, Nurturing) | |
| `Proposal_Sent_Date__c` | Proposal Sent Date | date | |
- Stages: Qualification → Proposal → Negotiation → Closed Won / Closed Lost

---

## Regras de interpretação — Prospecção

### Opportunity
- Uma Opp **só é criada quando há reunião agendada com interesse em explorar contratação da RGS**
- Account com dados ricos mas sem Opp pode significar infos de fontes indiretas (pesquisa, terceiros, calls informais)
- **A data de criação de uma Opp não é dado relevante** — muitos sales devs só criam a Opp quando a reunião acontece

### Equity Deal (EquityDeal__c)
- **Buyer Demand**: conversa com buyer que mencionou interesse em target específico (mais relevante)
- **Idea**: ideia interna do time para testar (menos relevante)
- Campo `Idea_Marketing_Stage__c` indica o estágio
- Campo `Data_da_demanda__c` indica quando a demanda foi levantada

### Lead → Account
- Lead é criado quando mapeamos uma empresa/pessoa
- Conversão para Account indica avanço no relacionamento
- `Lead_Originator__r.Name` = quem originou o lead
- Gap grande entre conversão e primeiro Event/Opp pode indicar falta de priorização

### Tier (buyers e targets)
- Campo `Tier__c` no Account classifica em 1, 2, 3
- Tier 1 sem atividade (Events/EQDs) é mais grave que Tier 3 sem atividade
