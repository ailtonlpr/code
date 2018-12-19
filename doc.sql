###################################################################
# PROCESSO LASA - 1
###################################################################

-- Link para execução manual
-- https://www.sisconnects.com.br/admin/cron/integracao_r/15

###########################################################
# PASSOS
###########################################################

### Acesso FTP 'LASA/LASA/input' - Vejo os arquivos que estão listados
### Executo 
### "SELECT * FROM integracao_log where integracao_id = 15 and deletado = 0 order by integracao_log_id desc;"
### Verifico se processamos todos arquivos disponiblizado pelo cliente "LASA"

### QUERY

SELECT * FROM integracao where integracao_id = 15; -- LASA - EQUIPAMENTOS NOVOS
-- Verificando se o arquivo já foi processado. "processamento_fim" vázio
SELECT * FROM integracao_log where integracao_id = 15 and deletado = 0 order by integracao_log_id desc;
-- Ver se está rodando
SELECT * FROM integracao_log_detalhe where integracao_log_id = 551; --   tot 629
-- Tempo total de execução
SELECT TIMEDIFF(processamento_fim,processamento_inicio) as TempoProcessamento 
FROM integracao_log where integracao_id = 15 and deletado = 0 and integracao_log_id = 551;
-- Pela quantidade de linhas retornadas eu sei se continua rodando. 
-- Aqui são as linhas que vieram no arquivo (menos h - t)

## Após identificar fazer o processamento do item não executado.

################################################################
#### 2 #####
################################################################

-- Identificando a integração a ser executada.
-- proxima_execucao (tem que estar de acordo | status - Tem que ser 'A')
SELECT * FROM integracao where integracao_id = 15; -- LASA - EQUIPAMENTOS NOVOS

##########################################
### PROCESSANDO O ARQUIVO NO LINK ABAIXO
##########################################
-- https://www.sisconnects.com.br/admin/cron/integracao_r/15

### FAÇA O ACOMPANHAMENTO DO ARQUIVO CONFORME PASSOS ACIMA

### APÓS TERMINAR DE PROCESSAR - VER OS STATUS - CONFORME QUERYS ABAIXO 

-- SELECT * FROM integracao_log_detalhe_erro;

#********* RESULTADO DO PROCESSAMENTO *********
SELECT integracao_id, integracao, processamento_inicio, nome_arquivo, quantidade_registros, stat, count(1) as c, if(quantidade_registros=0, 0, count(1)/quantidade_registros*100) as percent
FROM (
	SELECT i.integracao_id, i.nome as integracao, date_format(il.processamento_inicio, '%d/%m/%Y') as processamento_inicio, il.nome_arquivo, il.quantidade_registros - 2 as quantidade_registros, IF(ild.integracao_log_status_id = 5, 'ERRO', IF(ild.integracao_log_status_id = 3, 'AG. RETORNO', 'OK')) AS stat, ild.chave
	FROM integracao_log il 
	join integracao_log_detalhe ild on il.integracao_log_id = ild.integracao_log_id
    join integracao i on il.integracao_id = i.integracao_id
    where 1=1
    and il.deletado = 0
    and il.integracao_log_id = 551
	#where il.integracao_id = 11 and il.integracao_log_id = 75
) as x
group by integracao_id, integracao, processamento_inicio, nome_arquivo, quantidade_registros, stat;

#********* ENTRADA - RESULTADO DOS ERROS PROCESSAMENTO RESUMIDO *********
SELECT `DATA PROCESSAMENTO`, `ARQUIVO`, `ERRO`, `TRANSAÇÃO`, count(1) q
FROM (
SELECT date_format(il.processamento_inicio, '%d/%m/%Y') as `DATA PROCESSAMENTO`, il.nome_arquivo AS `ARQUIVO`
, IF(ild.integracao_log_status_id = 5, 'ERRO', IF(ild.integracao_log_status_id = 3, 'AG. RETORNO', 'OK')) AS `STATUS`
, ilde.nome `ERRO`, ildc.msg `DETALHE ERRO`, ildd.tipo_transacao `TIPO TRANSAÇÃO`
, IF(ildd.tipo_transacao = 'NS', 'EMISSAO', IF(ildd.tipo_transacao IN('XS','XX'), 'CANCELAMENTO', 'IGNORADO')) AS `TRANSAÇÃO`
, ildd.num_apolice AS `APOLICE`, ildd.vigencia AS `VIGENCIA`, ildd.cpf `CPF`, ildd.sexo `SEXO`, ildd.endereco `ENDEREÇO`, ildd.telefone `TELEFONE`
, ildd.cod_loja `COD LOJA`, ildd.cod_vendedor `COD VENDEDOR`, ildd.cod_produto_sap `COD PRODUTO SAP`, ildd.ean `EAN`, ildd.marca `MARCA`, ildd.equipamento_nome `EQUIPAMENTO`
, ildd.nota_fiscal_valor `VALOR NF`, ildd.nota_fiscal_data `DATA NF`, ildd.nota_fiscal_numero `NRO NF`, ildd.premio_liquido `PREMIO BRUTO`, '' `PREMIO LIQUIDO`, 'COBRANÇA DE TERCEIROS' `FORMA DE PAGAMENTO`, ildd.num_parcela `NRO PARCELA`

FROM integracao_log il 
join integracao_log_detalhe ild on il.integracao_log_id = ild.integracao_log_id
left join integracao_log_detalhe_campo ildc on ild.integracao_log_detalhe_id = ildc.integracao_log_detalhe_id
left join integracao_log_detalhe_erro ilde on ildc.integracao_erros_id = ilde.integracao_log_detalhe_erro_id
left join integracao_log_detalhe_dados ildd on ild.integracao_log_detalhe_id = ildd.integracao_log_detalhe_id
where il.integracao_log_id = 551 and ild.integracao_log_status_id = 5
) as x
group by `DATA PROCESSAMENTO`, `ARQUIVO`, `ERRO`, `TRANSAÇÃO`
;

#********* ENTRADA - RESULTADO DOS ERROS PROCESSAMENTO DETALHADO *********
SELECT '' AS `DATA RECEBIMENTO`, date_format(il.processamento_inicio, '%d/%m/%Y') as `DATA PROCESSAMENTO`, il.nome_arquivo AS `ARQUIVO`
, IF(ild.integracao_log_status_id = 5, 'ERRO', IF(ild.integracao_log_status_id = 3, 'AG. RETORNO', 'OK')) AS `STATUS`
, ilde.nome `ERRO`, ildc.msg `DETALHE ERRO`, ildd.tipo_transacao `TIPO TRANSAÇÃO`
, IF(ildd.tipo_transacao = 'NS', 'EMISSAO', IF(ildd.tipo_transacao IN('XS','XX'), 'CANCELAMENTO', 'OUTROS')) AS `TRANSAÇÃO`
, ildd.num_apolice AS `APOLICE`, ildd.vigencia AS `VIGENCIA`, ildd.cpf `CPF`, ildd.sexo `SEXO`, ildd.endereco `ENDEREÇO`, ildd.telefone `TELEFONE`
, ildd.cod_loja `COD LOJA`, ildd.cod_vendedor `COD VENDEDOR`, ildd.cod_produto_sap `COD PRODUTO SAP`, ildd.ean `EAN`, ildd.marca `MARCA`, ildd.equipamento_nome `EQUIPAMENTO`
, ildd.nota_fiscal_valor `VALOR NF`, ildd.nota_fiscal_data `DATA NF`, ildd.nota_fiscal_numero `NRO NF`, ildd.premio_liquido `PREMIO BRUTO`, '' `PREMIO LIQUIDO`, 'COBRANÇA DE TERCEIROS' `FORMA DE PAGAMENTO`, ildd.num_parcela `NRO PARCELA`

FROM integracao_log il 
join integracao_log_detalhe ild on il.integracao_log_id = ild.integracao_log_id
left join integracao_log_detalhe_campo ildc on ild.integracao_log_detalhe_id = ildc.integracao_log_detalhe_id
left join integracao_log_detalhe_erro ilde on ildc.integracao_erros_id = ilde.integracao_log_detalhe_erro_id
left join integracao_log_detalhe_dados ildd on ild.integracao_log_detalhe_id = ildd.integracao_log_detalhe_id
where il.integracao_log_id = 551 and ild.integracao_log_status_id = 5
;
###########################################################################
# Validamos o que processou até aqui (Se deu erro da nossa parte verificar)
############################################################################


SELECT * FROM integracao_log where integracao_log_id = 519;


#------------------------------------------------------------------------------------
#####################################################################################
#### 3 CTA #####
#####################################################################################

-- Link para execução manual
-- https://www.sisconnects.com.br/admin/cron/integracao_s/9
-- http://econnects-h.jelastic.saveincloud.net/admin/cron/integracao_s/9

## VERIFICANDO SE TEM ALGO QUE FOI PROCESSADO

SELECT * FROM integracao where integracao_id in(9,10,11);
SELECT * FROM integracao where integracao_id in(30,31,32); -- RASTRECALL TPA 020
SELECT * FROM integracao where integracao_id in(81,82,83); -- RASTRECALL TPA 015
SELECT * FROM integracao where integracao_id in(33,34,35); -- SOFTBOX  		
SELECT * FROM integracao where integracao_id in(40,41,42); -- Decoskin 	

SELECT * FROM integracao_detalhe where integracao_id in(81,82,83);
select * from integracao_layout where integracao_id in(81,82,83) and tipo = 'H'; 
select * from integracao_layout where integracao_id in(83);

-- Verificando se o arquivo já foi processado. "processamento_fim" vázio

set @integracao_id := 9;

SELECT
@integracao_id as integracao_id, 
max(integracao_log_id) as integracao_log_id, 
IF(processamento_fim IS NULL,'EM PROCESSAMENTO','PROCESSAMENTO FINALIZADO') AS 'STATUS',
TIMEDIFF(processamento_fim,processamento_inicio) as TempoProcessamento  
FROM integracao_log where integracao_id = @integracao_id and deletado = 0 order by integracao_log_id desc;

SELECT * FROM integracao_log where integracao_id = @integracao_id and deletado = 0 order by integracao_log_id desc;

-- Ver se está rodando
SELECT * FROM integracao_log_detalhe where integracao_log_id = 2335; 
SELECT * FROM integracao_log_detalhe_campo where integracao_log_detalhe_id = 53715;
-- Pela quantidade de linhas retornadas eu sei se continua rodando. 

## Estando correto posso rodar 9-10-11


#********* RESULTADO DO PROCESSAMENTO *********
# VIDE FUNÇÂO ACIMA

# Estando OK (CLIENTE - FEITO)

# validações
SELECT * FROM integracao where integracao_id = 11;

SELECT * FROM integracao_log where integracao_id = 11 and deletado = 0 order by integracao_log_id desc;

-- https://www.sisconnects.com.br/admin/cron/integracao_s/10

-- Ver se está rodando
SELECT * FROM integracao_log_detalhe where integracao_log_id = 561; -- 393


-- Pela quantidade de linhas retornadas eu sei se continua rodando. 

SELECT integracao_id, integracao, processamento_inicio, nome_arquivo, quantidade_registros, stat, count(1) as c, if(quantidade_registros=0, 0, count(1)/quantidade_registros*100) as percent
FROM (
	SELECT i.integracao_id, i.nome as integracao, date_format(il.processamento_inicio, '%d/%m/%Y') as processamento_inicio, il.nome_arquivo, il.quantidade_registros - 2 as quantidade_registros, IF(ild.integracao_log_status_id = 5, 'ERRO', IF(ild.integracao_log_status_id = 3, 'AG. RETORNO', 'OK')) AS stat, ild.chave
	FROM integracao_log il 
	join integracao_log_detalhe ild on il.integracao_log_id = ild.integracao_log_id
    join integracao i on il.integracao_id = i.integracao_id
    where 1=1
    and il.deletado = 0
    and il.integracao_log_id = 561
	#where il.integracao_id = 11 and il.integracao_log_id = 75
) as x
group by integracao_id, integracao, processamento_inicio, nome_arquivo, quantidade_registros, stat;

# NO FTP


#------------------------------------------------------------------------------------
#####################################################################################
#### 4 CTA - SINISTRO #####
#####################################################################################

-- Link para execução manual
-- https://www.sisconnects.com.br/admin/cron/integracao_s/20
-- http://econnects-h.jelastic.saveincloud.net/admin/cron/integracao_s/20

# DEPOIS DE TER GERADO O CTA, FAÇO O SINISTRO 

#ex: SELECT * FROM integracao where integracao_id = 20; 

# validações
SELECT * FROM integracao WHERE integracao_id = 20;

SELECT * FROM integracao_log WHERE integracao_id = 20 and deletado = 0 order by integracao_log_id desc;

SELECT * FROM integracao_log_detalhe WHERE integracao_log_id = 567;

######################################################
-- PROCESSAMENTO DE RETORNO
######################################################

-- Link para execução manual
-- https://www.sisconnects.com.br/admin/cron/integracao_r/14
-- http://econnects-h.jelastic.saveincloud.net/admin/cron/integracao_r/14


# IDENTIFICAR O RETORNO A SER EXECUTADO
#ex: SELECT * FROM integracao where integracao_id = 14; -- LASA

# RODA TODOS OS ARQUIVOS DE RETORNO

### -- Acesso o FTP e vejo se há arquivos de retorno (Ex: /LASA/CTA/Input )

set @integracao_id := 77; -- prod 14 | homol 77
SELECT * FROM integracao where integracao_id = @integracao_id;
/*
UPDATE `sisconnects`.`integracao` SET `proxima_execucao`='2018-12-13 01:00:00', `status` = 'A'  
WHERE `integracao_id`= @integracao_id;
*/

-- Verificando se o arquivo já foi processado. "processamento_fim" vázio
SELECT * FROM integracao_log where integracao_id = @integracao_id and deletado = 0 order by integracao_log_id desc;

-- Ver se está rodando
SELECT * FROM integracao_log_detalhe where integracao_log_id = 2422;

SELECT * FROM integracao_log_detalhe_campo where integracao_log_detalhe_id = 55539; 

-- cd_tpa     
-- cd_cliente 1500

# PROCESSAR OS RETORNOS

### FAZENDO UMA ANALISE
### IDENTIFICO O ARQUIVO DE ENVIO DO CLIENTE
#SELECT * FROM integracao   
# DEPOIS VEJO OS LOGS 
# IDENTIFICO O NOME DO ARQUIVO QUE DESEJO VERIFICAR EX: 'C01.LASA.CLIENTE-RT-0110-20181130.TXT'
# TRANSFORMO PARA 'C01.LASA.CLIENTE-EV-0110-20181130.TXT' PARA ACHAR E FAÇO A ANALISE
select * from integracao_log where integracao_id = 78;

#UPDATE `sisconnects`.`integracao` SET `proxima_execucao`='2018-12-07 01:00:00' WHERE `integracao_id`='14';

#Depois devo tratar todos que foram processados hoje
#Identifico aqui "SELECT * FROM integracao_log where integracao_id = 14 and deletado = 0 order by integracao_log_id desc;"


#******** SAÍDA ********
select #ild.integracao_log_id, il.nome_arquivo, replace(il.nome_arquivo, '-EV-', '-RT-'), l.nome_arquivo
date_format(il.processamento_inicio, '%d/%m/%Y') as `DATA PROCESSAMENTO`, il.nome_arquivo AS `ARQUIVO`
, ild.chave AS `ID`, IF(ild.integracao_log_status_id = 5, 'ERRO', IF(ild.integracao_log_status_id = 3, 'AG. RETORNO', 'OK')) AS `STATUS`
, ildc.msg `DETALHE ERRO`
from integracao_log il 
#join integracao_log_detalhe ld on il.integracao_log_id = ld.integracao_log_id
left join integracao_log l on replace(il.nome_arquivo, '-EV-', '-RT-') = l.nome_arquivo
join integracao_log_detalhe ild on l.integracao_log_id = ild.integracao_log_id #and ild.chave like concat(ld.chave, '%')
left join integracao_log_detalhe_campo ildc on ild.integracao_log_detalhe_id = ildc.integracao_log_detalhe_id
where il.integracao_id = 78 and il.integracao_log_id = 2426 #and ild.integracao_log_status_id = 5
;


select * from cliente where cliente_id = '7840001';


###################################################
# ATUALIZANDO OS RETORNOS SE NECESSÁRIOS
###################################################

-- '784000100000000'
-- 
set @num_apolice := '784000100001308';

#CTA cliente
select c.cliente_id, ly.nome_arquivo, ldy.* 
from apolice a
join pedido p on a.pedido_id = p.pedido_id
join cotacao c on p.cotacao_id = c.cotacao_id
join integracao_log_detalhe ldy on ldy.chave = c.cliente_id
join integracao_log ly on ldy.integracao_log_id = ly.integracao_log_id and ly.integracao_id = 9
join integracao i on ly.integracao_id = i.integracao_id
where a.num_apolice = @num_apolice
and ly.deletado = 0
and i.tipo = 'S'
;

#CTA Parcela / Comissao
select c.cliente_id, a.pedido_id, lx.nome_arquivo, ld.integracao_log_detalhe_id, ldc.msg, ld.criacao, ld.integracao_log_status_id, ld.* 
from apolice a
join integracao_log_detalhe ld on a.num_apolice = left(ld.chave, locate('|', ld.chave )-1)
join integracao_log lx on ld.integracao_log_id = lx.integracao_log_id
join integracao i on lx.integracao_id = i.integracao_id
left join integracao_log l on lx.nome_arquivo = replace(l.nome_arquivo, '-RT-', '-EV-') and l.deletado = 0 and l.integracao_id in(select integracao_id from integracao where tipo = 'R')
left join integracao_log_detalhe ldr on ldr.integracao_log_id = l.integracao_log_id and a.num_apolice = ldr.chave and ldr.chave = left(ld.chave, locate('|', ld.chave )-1)
join pedido p on a.pedido_id = p.pedido_id
join cotacao c on p.cotacao_id = c.cotacao_id
left join integracao_log_detalhe_campo ldc on ldr.integracao_log_detalhe_id = ldc.integracao_log_detalhe_id
where a.num_apolice = @num_apolice
and ld.deletado = 0
and lx.deletado = 0
and i.tipo = 'S'
order by lx.nome_arquivo
;


#UPDATE CTA cliente
/*
update apolice a
join pedido p on a.pedido_id = p.pedido_id
join cotacao c on p.cotacao_id = c.cotacao_id
join integracao_log_detalhe ldy on ldy.chave = c.cliente_id
join integracao_log ly on ldy.integracao_log_id = ly.integracao_log_id and ly.integracao_id = 9
join integracao i on ly.integracao_id = i.integracao_id
set ldy.integracao_log_status_id = 6 
where a.num_apolice = @num_apolice
#and ly.nome_arquivo = 'C01.LASA.CLIENTE-EV-0109-20181130.TXT'
and ly.deletado = 0
and i.tipo = 'S';
*/

/*
select @@session.SQL_SAFE_UPDATES;
set @@session.SQL_SAFE_UPDATES = 0;
*/

#UPDATE CTA Parcela / Comissao
/*
update apolice a
join integracao_log_detalhe ld on a.num_apolice = left(ld.chave, locate('|', ld.chave )-1)
join integracao_log lx on ld.integracao_log_id = lx.integracao_log_id
join integracao i on lx.integracao_id = i.integracao_id
left join integracao_log l on lx.nome_arquivo = replace(l.nome_arquivo, '-RT-', '-EV-') and l.deletado = 0 and l.integracao_id in(select integracao_id from integracao where tipo = 'R')
left join integracao_log_detalhe ldr on ldr.integracao_log_id = l.integracao_log_id and a.num_apolice = ldr.chave and ldr.chave = left(ld.chave, locate('|', ld.chave )-1)
join pedido p on a.pedido_id = p.pedido_id
join cotacao c on p.cotacao_id = c.cotacao_id
left join integracao_log_detalhe_campo ldc on ldr.integracao_log_detalhe_id = ldc.integracao_log_detalhe_id
set ld.integracao_log_status_id = 6
where a.num_apolice = @num_apolice
and ld.deletado = 0
and lx.deletado = 0
and i.tipo = 'S'
;
*/

####################################################
-- SINISTRO
####################################################

-- Link para execução manual
-- https://www.sisconnects.com.br/admin/cron/integracao_s/14
-- http://econnects-h.jelastic.saveincloud.net/admin/cron/integracao_s/14

# SINISTRO (SE OS 3 ARQUIVOS DE CTA DERAM OK)
# REALIZAR O PROCESSO DE SINISTRO


### MOVIMENTAÇÃO
# (1)  20 - CTA - SINISTRO - AVISO
# (2)  21 - CTA - SINISTRO - RESERVA A MAIOR
# (3)  22 - CTA - SINISTRO - RESERVA A MENOR
# (4)  23 - CTA - SINISTRO - PAGAMENTO TOTAL
# (5)  24 - CTA - SINISTRO - PAGAMENTO PARCIAL
# (6)  25 - CTA - SINISTRO - CANCELAMENTO
# (7)  26 - CTA - SINISTRO - REATIVAÇÃO




######################################################
-- Checando o que aconteceu 
######################################################

# CONVERTENDO O NÚMERO DA APOLICE
select concat("7840001",right('717100700000037',8)); 


SELECT i.nome, ils.nome, il.nome_arquivo, ld.* FROM integracao_log_detalhe ld 
inner join integracao_log il on il.integracao_log_id = ld.integracao_log_id
inner join integracao i on i.integracao_id = il.integracao_id
inner join integracao_log_status ils on ils.integracao_log_status_id = ld.integracao_log_status_id
where chave like '7840001    %';

###################################################################################################
# FAZENDO AS CORREÇÕES
###################################################################################################

# AQUI IDENTIFICAMOS O REGISTRO COM ERRO 
select ild.* from integracao_log il
            INNER JOIN integracao_log_detalhe ild ON ild.integracao_log_id = il.integracao_log_id 
            WHERE il.nome_arquivo LIKE 'C01.LASA.CLIENTE-EV-0109-20181130.TXT%'
            AND ild.integracao_log_status_id = 5
            AND ild.chave LIKE '7683%';

# DEPOIS VERIFIQUEI NA SQL DA INTEGRAÇÃO "9" EXEMPLO SE IRÁ RETORNAR O REGISTRO CORRIGIDO
# APÓS TER CERTEZA QUE O ERRO SERÁ CORRIGIDO. DEVO ATUALIZAR O STATUS PARA AGUARDANDO REENVIO
/*
update integracao_log il
            INNER JOIN integracao_log_detalhe ild ON ild.integracao_log_id = il.integracao_log_id 
            SET ild.integracao_log_status_id = 6
            WHERE il.nome_arquivo LIKE 'C01.LASA.CLIENTE-EV-0109-20181130.TXT%'
            AND ild.integracao_log_status_id = 5
            AND ild.chave LIKE '7683%';
*/

# CONVERTENDO O NÚMERO DA APOLICE
select concat("7840001",right('717100700000037',8)); 


# COMISSÃO
# NO FTP

SELECT * FROM integracao where integracao_id = 15; 


########################################################
# CLONANDO INTEGRAÇÕES
########################################################

#BUSCANDO AS INTEGRAÇÕES A SEREM CLONADAS
SELECT * FROM integracao where integracao_id in(83); -- 12 lacto | ocr 13
SELECT * FROM integracao_detalhe where integracao_id in(12);
SELECT * FROM integracao_layout where integracao_id in(12); 

/*
INSERT INTO integracao (
	SELECT null, parceiro_id, tipo, integracao_comunicacao_id, periodicidade_unidade, periodicidade, periodicidade_hora, proxima_execucao, ultima_execucao, nome, slug, descricao, script_sql, parametros, campo_chave, ambiente, host, porta, usuario, senha, diretorio, habilitado, status, before_execute, after_execute, before_detail, after_detail, sequencia, deletado, criacao, alteracao_usuario_id, alteracao 
    FROM integracao 
    where integracao_id in(32)
);
*/


#UPDATE integracao SET parceiro_id = '47', usuario = 'h-gbs-sis', senha = 'G3n3r4l1@#2050', diretorio = '/DECOSKIN/CTA/Output/' 
#WHERE integracao_id in(59,60,61,62,63,64,65);

#SELECT integracao_id, parceiro_id, nome, usuario, senha, diretorio FROM integracao where integracao_id in(59,60,61,62,63,64,65);

#----------------------------------------------------
#INSERT INTO integracao_detalhe (
#	SELECT null, 83, tipo, ordem, multiplo, script_sql, deletado, criacao, alteracao_usuario_id, alteracao
#    FROM integracao_detalhe 
#    where integracao_id in(32)
#);
#INSERT INTO integracao_detalhe (
#	SELECT null, 41, tipo, ordem, multiplo, script_sql, deletado, criacao, alteracao_usuario_id, alteracao
#    FROM integracao_detalhe 
#    where integracao_id in(34)
#);
#INSERT INTO integracao_detalhe (
#	SELECT null, 42, tipo, ordem, multiplo, script_sql, deletado, criacao, alteracao_usuario_id, alteracao
#    FROM integracao_detalhe 
#    where integracao_id in(35)
#);
#INSERT INTO integracao_detalhe (
#	SELECT null, 43, tipo, ordem, multiplo, script_sql, deletado, criacao, alteracao_usuario_id, alteracao
#    FROM integracao_detalhe 
#    where integracao_id in(36)
#);
#INSERT INTO integracao_detalhe (
#	SELECT null, 44, tipo, ordem, multiplo, script_sql, deletado, criacao, alteracao_usuario_id, alteracao
#    FROM integracao_detalhe 
#    where integracao_id in(37)
#);
#------------------------------------------

#INSERT INTO integracao_layout (
#	SELECT null, 44, tipo, ordem, multiplo, script_sql, deletado, criacao, alteracao_usuario_id, alteracao
#    FROM integracao_detalhe 
#    where integracao_id in(37)
#);

SELECT 
null, 83, IF(tipo = 'H',426,IF(tipo = 'D',427,IF(tipo = 'T',428,IF(tipo = 'F',429,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(32);

SELECT * FROM integracao_detalhe where integracao_id in(83);

SELECT * FROM integracao;

/*
INSERT INTO integracao_layout (
	SELECT 
null, 83, IF(tipo = 'H',426,IF(tipo = 'D',427,IF(tipo = 'T',428,IF(tipo = 'F',429,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(32)
);
*/


SELECT 
null, 41, IF(tipo = 'H',191,IF(tipo = 'D',192,IF(tipo = 'T',193,IF(tipo = 'F',194,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(34);  

SELECT * FROM integracao_detalhe where integracao_id in(41);

/*
INSERT INTO integracao_layout (
	SELECT 
null, 41, IF(tipo = 'H',191,IF(tipo = 'D',192,IF(tipo = 'T',193,IF(tipo = 'F',194,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(34)  
);
*/

SELECT 
null, 42, IF(tipo = 'H',198,IF(tipo = 'D',199,IF(tipo = 'T',200,IF(tipo = 'F',201,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(35);  

SELECT * FROM integracao_detalhe where integracao_id in(42);
/*
INSERT INTO integracao_layout (
	SELECT 
null, 42, IF(tipo = 'H',198,IF(tipo = 'D',199,IF(tipo = 'T',200,IF(tipo = 'F',201,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(35)  
);
*/



SELECT 
null, 43, IF(tipo = 'H',205,IF(tipo = 'D',206,IF(tipo = 'T',207,IF(tipo = 'F',208,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(36);  

SELECT * FROM integracao_detalhe where integracao_id in(41);
/*
INSERT INTO integracao_layout (
	SELECT 
null, 43, IF(tipo = 'H',205,IF(tipo = 'D',206,IF(tipo = 'T',207,IF(tipo = 'F',208,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(36)  
);
*/

SELECT 
null, 44, IF(tipo = 'H',212,IF(tipo = 'D',213,IF(tipo = 'T',214,IF(tipo = 'F',215,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(37);  

SELECT * FROM integracao_detalhe where integracao_id in(44);
/*
INSERT INTO integracao_layout (
	SELECT 
null, 44, IF(tipo = 'H',212,IF(tipo = 'D',213,IF(tipo = 'T',214,IF(tipo = 'F',215,0)))) as integracao_detalhe_id, tipo, ordem, nome, descricao, formato, campo_tipo, tamanho, obrigatorio, campo_log, `insert`, inicio, fim, nome_banco, function, valor_padrao, qnt_valor_padrao, str_pad, deletado, criacao, alteracao_usuario_id, alteracao
FROM integracao_layout il
WHERE il.integracao_id in(37)  
);
*/

### ATUALIZAR OS DADOS DA NOVA INTEGRAÇÃO

SELECT * FROM integracao_layout where integracao_id in(41); 

SELECT * FROM integracao where integracao_id in(40,41,42,43,44); 
SELECT * FROM integracao_detalhe where integracao_id in(40,41,42,43,44); 
SELECT * FROM integracao_layout where integracao_id in(40,41,42,43,44);

SELECT * FROM integracao_layout where integracao_id in(44);

SELECT * FROM produto_parceiro_apolice_range where produto_parceiro_id = 63;

SELECT * FROM  produto_parceiro;

SELECT * FROM integracao where integracao_id in(42); 
SELECT * FROM integracao_detalhe where integracao_id in(42); 

#############################################################
#DELETADO
#############################################################

select @@session.SQL_SAFE_UPDATES;
set @@session.SQL_SAFE_UPDATES = 0;

-- Ver se está rodando
set @integracao_id := 83;
/*
delete from integracao_log_detalhe_campo where integracao_log_detalhe_id IN(select integracao_log_detalhe_id from integracao_log_detalhe where integracao_log_id IN(select integracao_log_id from integracao_log where integracao_id = @integracao_id));
delete from integracao_log_detalhe where integracao_log_id IN(select integracao_log_id from integracao_log where integracao_id = @integracao_id);
delete from integracao_log where integracao_id = @integracao_id;
-- select * from integracao where integracao_id in(41);
UPDATE `sisconnects`.`integracao` SET `proxima_execucao`='2018-12-12 01:00:00' WHERE `integracao_id`='83';
UPDATE `sisconnects`.`integracao` SET `status`='A' WHERE `integracao_id`='83';
*/

SELECT * FROM integracao_detalhe where integracao_id = 41;



select * from integracao where integracao_id in(33,34,35);
select * from integracao_layout where integracao_id = 34 and tipo = 'D';
select * from integracao where integracao_id in(31,34);

select length('C01.DECOSKIN.CLIENTE-EV-0004-20181206.TX');


SELECT * FROM integracao where integracao_id = 41; -- LASA - EQUIPAMENTOS NOVOS
-- Verificando se o arquivo já foi processado. "processamento_fim" vázio
SELECT * FROM integracao_log where integracao_id = 41 and deletado = 0 order by integracao_log_id desc;
-- Ver se está rodando
SELECT * FROM integracao_log_detalhe where integracao_log_id = 2314; 

SELECT * FROM integracao_log_detalhe_campo order by 1 desc; 

## Só Softbox que não passa o número da apolice



##------------------------------------------------------------------------
## Processo de validação de arquivo (Leandro) 
##
/*

1 - Carga (e aceita os dados)
2 - Trinca (valida a trinca)
3 - Xml - (gerar o xml - baseado no sistema "oim" para gerar o documento final )

*/


###############################################################################
# CALCULO
###############################################################################
/*
R$ 6,49 <-> 100% + IOF (7,38%)
R$ 6,49 --> 107,38
x --- 100

CALCULO
( R$ 6,49 / 107,38 ) * 100  "CONSIDERO 4 ÚLTIMOS DIGITOS DEPOIS DA VIRGULA"

RESULTADO .:: R$ 6,043956044  ---> R$ 6,044

*/


