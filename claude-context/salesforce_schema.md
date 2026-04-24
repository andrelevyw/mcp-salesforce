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

## Objeto: DCM_Project__c (Projetos DCM)

### Campos principais
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `Name` | DCM Project Name | string | Codinome do projeto |
| `Client__c` | Client | string | Nome do cliente (texto, não reference) |
| `Status__c` | Status | picklist | **Ativo, Estaleiro, Morto, Liquidado** |
| `Stage__c` | Stage | picklist | **Material preparation, Structuring/Distributing, Closing/Settlement** |
| `Stage_Distribuition__c` | Stage Distribuition | picklist | **Investor list preparation, Roadshow, Investor feedback, Settlement process** |
| `DCM_Type__c` | DCM Type | string | Tipo do produto DCM (fórmula) |
| `Fee_total_bruto_DCM_R_mm__c` | Fee total bruto DCM (R$mm) | currency | Fee bruto |
| `Fee_canal_estimado_R_mm__c` | Fee canal estimado (R$mm) | currency | Fee do canal de distribuição |
| `Valor_da_capta_o__c` | Valor da captação | currency | Montante da operação |
| `Prob_success__c` | Prob. success | percent | Probabilidade de sucesso |
| `Execution_Leader__c` | Execution Leader | string | Líder de execução (fórmula) |
| `Distribution_Leader__c` | Distribution Leader | string | Líder de distribuição (fórmula) |
| `Oportunidade__c` | Opportunity | reference → Opportunity | Opp de origem |
| `Mandate_signed__c` | Mandate signed | boolean | Mandato assinado |

### Datas do pipeline
| Campo API | Label | Notas |
|---|---|---|
| `Kick_Off__c` | Kick-Off | Início do mandato |
| `Roadshow_Start__c` | Roadshow Start | Início do roadshow |
| `First_investor_approval__c` | First investor approval | Primeira aprovação de investidor |
| `Settlement__c` | Settlement | Liquidação |
| `Estimated_closing__c` | Estimated closing | Closing estimado |

### Referências
- `Client__c` é string (fórmula), não reference — diferente do M_A_Project__c

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
- Stages e probabilidades: Qualification (10%) → Proposal (75%) → Negotiation (90%) → Closed Won (100%) / Closed Lost (0%)
- **Closed Won = mandato assinado** (início da execução), não deal fechado. A execução vive no M_A_Project__c

---

## Objeto: Account (Empresas — clientes, targets, buyers)

### Campos-chave
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `Name` | Account Name | string | Nome da empresa |
| `Type` | Account Type | picklist | **Target Sophisticated, Target Unsophisticated, Buyer Local, Buyer Foreign, Acquired**, Consultant, Legal Adviser, Bank, Investor, Wealth Manager, Auditor, Independente, Press, Supplier |
| `Tier__c` | Tier | picklist | **1, 2, 3** — classificação M&A |
| `Tier_DCM__c` | Tier DCM | picklist | **1, 2, 3** — classificação DCM |
| `OwnerId` | Owner | reference → User | Dono da account |
| `Originating_Partner__c` | Originating Partner | reference → User | Quem originou |

### Classificação setorial (GICS RGS — hierarquia ativa)
| Campo API | Label | Notas |
|---|---|---|
| `Coverage_novo__c` | GICS RGS 1 | Nível 1: Agronegocio, Consumo, Educacao, Energia, FIG, Industrials, Quimicos, Saude, Sponsors, Tech, Varejo, Business services, Real Estate, Infraestrutura, Telecom, Mineracao, Florestas e derivados, Midia e entretenimento |
| `Segmento__c` | GICS RGS 2 | Nível 2: ~140 sub-setores (Hospital, Fintech, Solar, ISP, Private Equity, etc.) |
| `Subsegmento__c` | GICS RGS 3 | Nível 3: ~200 sub-sub-setores |
| `GICS_RGS_4__c` | GICS RGS 4 | Nível 4 (multipicklist) |

Existe hierarquia paralela padrão (`GICS_1__c` a `GICS_6__c`) e campos legados Zoho (`Industry_Primary_Zoho__c`, `Industry_Secondary_Zoho__c`). Preferir a hierarquia GICS RGS.

### Dados financeiros
| Campo API | Label | Tipo |
|---|---|---|
| `Revenues__c` | Revenues (R$mm) | currency |
| `EBITDA__c` | EBITDA (R$mm) | currency |
| `Net_Debt__c` | Net Debt (R$mm) | currency |
| `Net_Income__c` | Net Income | currency |
| `YoY_growth__c` | YoY growth | percent |

### Campos de buyer/sponsor
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `AUM_em_R_bilh_es__c` | AUM (R$ bilhões) | currency | |
| `Minimum_Ticket_Size__c` | Min Ticket (USDmm) | currency | |
| `Maximum_Ticket_Size__c` | Max Ticket (USDmm) | currency | |
| `Control__c` | Control | boolean | Faz deals de controle |
| `Minority__c` | Minority | boolean | Faz deals de minoria |
| `Validado_com_comprador__c` | Active buyer demand? | boolean | |

### Campos de atividade/nurturing
| Campo API | Label | Tipo |
|---|---|---|
| `Next_Action__c` | Next Action | textarea |
| `Next_Action_Date__c` | Next Action Date | date |
| `Last_Coverage_Meeting_or_Checklist__c` | Last Coverage Meeting | date |
| `Key_Account__c` | Special Nurturing | boolean |
| `LastActivityDate` | Last Activity | date |

### Campos DCM no Account
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `DCM_Buyer_new__c` | DCM Buyer | boolean | Fit para produtos DCM |
| `Tipo_DCM__c` | Tipo DCM | picklist | Asset, FO/MFO, Wealth, AAI, Fundacao, Seguradora, UHNWI |
| `AUM_cr_dito_privado__c` | AUM crédito privado (R$ bilhões) | currency | |
| `Next_Action_DCM__c` | Next Action DCM | textarea | |
| `Next_Action_Date_DCM__c` | Next Action Date DCM | date | |

### Campos de identidade
| Campo API | Label | Tipo |
|---|---|---|
| `CNPJ__c` | CNPJ | string |
| `Website` | Website | url |
| `Capital_Aberto__c` | Capital Aberto? | picklist — Fechado, Categoria B, Categoria A, Listado |
| `Tech_Type__c` | Tech Type | picklist — Agritech, Cybersecurity, Edtech, Fintech, Healthtech, Logtech, Proptech, Retail Tech, Software / Hardware |

---

## Objeto: Event (Reuniões e atividades)

### Campos-chave
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `Subject` | Subject | combobox | Assunto da reunião |
| `WhoId` | Name | reference → Contact/Lead | Pessoa relacionada |
| `WhatId` | Related To | reference → Account/Opportunity/M_A_Project__c/etc. | Registro relacionado |
| `ActivityDateTime` | Due Date Time | datetime | Data/hora |
| `ActivityDate` | Due Date Only | date | Data |
| `OwnerId` | Assigned To | reference → User | Responsável |
| `IsAllDayEvent` | All-Day Event | boolean | |
| `Description` | Description | textarea | |

### Uso na RGS
- Events medem **atividade de prospecção**: QMs, first meetings, reuniões com buyers
- `WhatId` linkado a Account ou Opportunity indica reunião comercial
- Para medir atividade de um sócio: filtrar por `OwnerId` e período

---

## Objeto: Lead (Leads — empresas/pessoas mapeadas)

### Campos-chave
| Campo API | Label | Tipo | Notas |
|---|---|---|---|
| `FirstName` / `LastName` | Nome | string | |
| `Company` | Company | string | Empresa |
| `Status` | Status | picklist | **Qualified, Open, Working, Archived Could not Connect, Unqualified** |
| `LeadSource` | Lead Source | picklist | **Outbound Broker, Outbound Cold, Outbound Network, Inbound Network, Inbound Broker, Cold Inbound** |
| `Lead_Originator__c` | Originating Partner | reference → User | Quem originou |
| `Lead_Source_io__c` | Source Type | picklist | **Inbound, Outbound** |
| `IsConverted` | Converted | boolean | |
| `ConvertedDate` | Converted Date | date | |
| `ConvertedAccountId` | Converted Account | reference → Account | |
| `Tier__c` | Tier | picklist | 1, 2, 3 |
| `M_A__c` | M&A | boolean | Lead relevante para M&A |
| `DCM__c` | DCM | boolean | Lead relevante para DCM |
| `Filtro__c` | Filtro | picklist | **Fit for RGS, No Fit for RGS, TBD** |
| `Pos_or_Neg_Conversion__c` | Pos. or Neg. Conversion | picklist | **Positive, Negative** |

### Classificação setorial
Mesma hierarquia GICS RGS do Account: `Coverage_novo__c`, `Segmento__c`, `Subsegmento__c`

### Dados financeiros
`Revenues__c`, `EBITDA__c`, `Net_Debt__c`, `Faturamento_estimado_R_mm__c`

### Stage pipelines no Lead
- `Campaign_Stage__c` — estágio em campanhas outbound
- `Mkt_Sounding_Stage__c` — estágio no market sounding (Lead usado como buyer target)
- `Partner_Broker_Stage__c` — estágio no canal de parceiros/brokers

---

## Mapeamento User → Nome (sócios e pessoas-chave)

| Nome | User Id |
|---|---|
| André Levy | `0058V00000COTHIQA5` |
| Fabio Jamra | `0051H000009h1UQQAY` |
| Giovana Domine | `0058V00000E5mXQQAZ` |
| Guilherme Stuart | `0051H000007VwBfQAK` |
| Henrique Polo | `0058V00000CDJzxQAH` |
| Hugo Pacheco | `0051H000007VwBkQAK` |
| Pedro Scharam | `0051H000009h1UVQAY` |
| Renato Stuart | `0051H000009h0SwQAI` |
| Stephanie Chu | `0058V00000E5ibOQAR` |

---

## Regras de interpretação — Prospecção

### Opportunity
- Uma Opp **só é criada quando há reunião agendada com interesse em explorar contratação da RGS**
- Account com dados ricos mas sem Opp pode significar infos de fontes indiretas (pesquisa, terceiros, calls informais)
- **A data de criação de uma Opp não é dado relevante** — muitos sales devs só criam a Opp quando a reunião acontece

### EquityDeal__c (junção buyer ↔ seller)

Objeto de junção bilateral: conecta um **buyer** (Account ou Lead) a um **seller** (Account ou Lead), opcionalmente vinculado a um M&A Project. Tem dois usos:
- **Durante execução**: registra cada comprador abordado num processo de M&A
- **Standalone**: matchmaking entre oferta e demanda, fora de mandato

**Lookups principais:**
| Campo API | Label | Referencia | Notas |
|---|---|---|---|
| `BuyerAccount__c` | BuyerAccount | Account | Lado comprador |
| `BuyerLead__c` | BuyerLead | Lead | Lado comprador (se ainda Lead) |
| `Buyer_Contact__c` | Buyer Contact | Contact | Pessoa do comprador |
| `SellerAccount__c` | SellerAccount | Account | Lado vendedor |
| `SellerLead__c` | SellerLead | Lead | Lado vendedor (se ainda Lead) |
| `Seller_Contact__c` | Seller Contact | Contact | Pessoa do vendedor |
| `Sell_Side_Project__c` | M&A Project | M_A_Project__c | Projeto de execução (opcional — permite EQDs standalone) |

**Campos de classificação:**
| Campo API | Label | Tipo | Valores |
|---|---|---|---|
| `Origem_do_EQD__c` | Origem do EQD | picklist | **Idea, Buyer Demand, Seller Demand** |
| `EQD_Status__c` | EQD Status | picklist | **Active, Dead, Waiting for feedback** |
| `Deal_Rating__c` | Deal Rating | picklist | **Hot, Warm, Cold, Dead** |
| `Buyer_Stage__c` | Buyer Stage | picklist | **Idea, Buyer Demand, Waiting Buyer Feedback, Buyer Approved, Buyer Declined, Future Buyer Demand** |
| `Seller_Stage__c` | Seller Stage | picklist | **Idea, Seller Demand, Waiting Seller Feedback, Seller Approved, Seller Declined, Future Seller Demand** |
| `Idea_Marketing_Stage__c` | Idea/Marketing Stage | picklist | **Present to Buyer, Waiting Buyer Feedback, Present to Seller, Waiting Seller Feedback** |
| `Deal_Stage__c` | Deal Stage (mkt sounding) | picklist | **Approved by client, Email sent, NDA, Infopack Sent, NBO, Due Diligence, Contracts, Closing** |
| `Tier__c` | Tier | picklist | **Tier 1, Tier 2, Tier 3** |

**Campos de inteligência:**
| Campo API | Label | Tipo |
|---|---|---|
| `Buyer_Feedback_1__c` | Buyer Feedback 1 | textarea |
| `Buyer_Feedback_2__c` | Buyer Feedback | textarea |
| `Feedback_type__c` | Feedback type | picklist — razões estruturadas de declínio (tese não se aplica, timing, porte, não olham Brasil, valuation, sem contato, etc.) |
| `Seller_Feedback__c` | Seller Feedback | textarea |
| `Latest_Insight_Buyer__c` | Buyer Latest Insight | string |
| `Comments__c` | Detalhamento da demanda | textarea |
| `Data_da_demanda__c` | Data da demanda | date |
| `Potential_Fee__c` | Potential Fee (R$mm) | currency |

**Nota:** não tem lookup para Opportunity — a conexão com o funil é via M_A_Project__c.

### Lead → Account
- Lead é criado quando mapeamos uma empresa/pessoa
- Conversão para Account indica avanço no relacionamento
- `Lead_Originator__r.Name` = quem originou o lead
- Gap grande entre conversão e primeiro Event/Opp pode indicar falta de priorização

### Tier (buyers e targets)
- Campo `Tier__c` no Account classifica em 1, 2, 3
- Tier 1 sem atividade (Events/EQDs) é mais grave que Tier 3 sem atividade
