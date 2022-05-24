/*******************************************/
USE CCPNA;
DECLARE @CodCROF	varchar(6);
DECLARE @Sede		varchar(2);
DECLARE @Nombre		varchar(50);
SET @Sede		= '01';
SET @CodCROF	= '103389';
SET @Nombre		= '%talk%';
/*******************************************/


select top 100 
cof.SUCR_CodSuc
,cof.CROF_CodCurso
,cof.CURS_CodCurso
,cof.CICL_CodCiclo
,cof.HORA_CodHora
,cof.SALO_CodSalon
,cof.CROF_Estado
,cof.CROF_Nombre
,cof.TRAB_Cod
,cic.CICL_Descripcion
,cic.CICL_CodCicloPrev
,cic.CICL_Estado
from		cursosofrecidos cof
inner join	ciclos			cic on cic.CICL_CodCiclo = cof.CICL_CodCiclo and cof.SUCR_CodSuc = @Sede and cof.SUCR_CodSuc = cic.SUCR_CodSuc
where		
cof.CROF_Nombre like @Nombre 
and cic.CICL_Estado = 'A'

SELECT
/*******************************************/
/*PARA REPORTES DE datos personales de ALUMNOS*/
/*******************************************/
/*
	--CLIENTE
	--mat.SUCR_CodSuc				as Sede
	CASE mat.SUCR_CodSuc
		When '01'	Then 'Arequipa'
		When '02'	Then 'Tacna'
		When '03'	Then 'Ilo'
		When '05'	Then 'Puno'
		When '07'	Then 'Juliaca'
		When '08'	Then 'Moquegua'
	ELSE 'Error'
	END as Sede
	,mat.CLTE_CodCli
	,cli.CLTE_Apellido
	,cli.CLTE_Nombre
	,cli.CLTE_fecNac
	
	--datos personales
	,FLOOR((CAST (GetDate() AS INTEGER) - CAST(CLTE_FecNac AS INTEGER)) / 365.25) AS Edad
	,cli.CLTE_DocIden
	,cli.CLTE_EMail
	,isnull(cli.CLTE_Tel1,'')				CLTE_Tel1
	,isnull(cli.[CLTE_Tel2],'')				CLTE_Tel2
	,isnull(cli.[CLTE_Celular],'')			CLTE_Celular
	,isnull(cli.[CLTE_TelOfPadre],'')		CLTE_TelOfPadre
	,isnull(cli.[CLTE_TelCelPadre],'')		CLTE_TelCelPadre
	,isnull(cli.[CLTE_TelOfMadre],'')		CLTE_TelOfMadre
	,isnull(cli.[CLTE_TelCelMadre],'')		CLTE_TelCelMadre
	,isnull(cli.[CLTE_TelContacEmerg],'')	CLTE_TelContacEmerg
	,isnull(cli.[CLTE_CelContacEmerg],'')	CLTE_CelContacEmerg
	
	
	--MATRICULA
	,mat.MATR_NotaFinal		as nota
	,mat.MATR_Aprobado		as Aprobado
	--,cof.CROF_CodCurso
	,cof.CROF_Nombre

	--salon
	,hor.HORA_Inicio		as Hora
	
	--CICLO
	,convert(varchar, cic.CICL_FecIniClass, 23)	as CICL_FecIniClass
	--,convert(varchar, cic.CICL_FecFin, 23)		as CICL_FecFin
	,cic.CICL_Descripcion

	--curso
	,CUR.CURS_Descripcion
	,TI2.TIPO_Desc1

	--FASE - PROGRAMA
	,TIP.TIPO_Desc1			AS Fase

	--CARRERA
	--,car.CARR_CodCarr
	,car.CARR_Nombre		AS Carrera		--SELECT * FROM CARRERAS
	--,car.CARR_Descripcion	AS CarreraDesc
	
	--trabajadores
	,tra.TRAB_Cod			as PROF_codigo
	,tra.TRAB_Apellido1		as PROF_apellido
	,tra.TRAB_Nombre1		as PROF_nombre
	
	*/
	
	
	
/*******************************************/
/*PARA DETALLE academico*/
/*******************************************/
	
	--CLIENTE
	mat.SUCR_CodSuc				as sede
	,mat.CLTE_CodCli
	,cli.CLTE_Apellido
	,cli.CLTE_Nombre
	,FLOOR((CAST (CICL_FecIniClass AS INTEGER) - CAST(CLTE_FecNac AS INTEGER)) / 365.25) AS Edad

	--MATRICULA
	,cof.CROF_CodCurso
	,cof.CROF_Nombre
	,mat.MATR_FecMat
	,mat.MATR_NotaFinal		as Nota
	,mat.MATR_Aprobado		as Aprobado
	
	--salon
	--,SAL.salo_codsalon
	--,sal.SALO_Descripcion
	--,hor.HORA_CodHora
	,hor.HORA_Inicio		as Hora
	--,HOR.HORA_Fin
	
	--CICLO
	--,cic.CICL_CodCiclo
	--,cic.TIPO_TCodTipoCiclo	TCL
	--,cic.TIPO_CCodTipoCiclo
	--,TIP.TIPO_CodTabla
	--,TIP.TIPO_Desc2		as 'TIPTIPO_Desc2'
	--,TIP.TIPO_DescC		as 'TIPTIPO_DescC'
	
	--SELECT * FROM TIPOS WHERE TIPO_CodTabla = 'FAS'
	--SELECT * FROM CICLOS		--select * from tipos WHERE TIPO_CodTabla = 'tcl'
	--SELECT * FROM CURSOS
	,convert(varchar, cic.CICL_FecIniClass, 23)	as CICL_FecIniClass
	,convert(varchar, cic.CICL_FecFin, 23)		as CICL_FecFin
	,cic.CICL_Descripcion
	,TIP.TIPO_CodTipo	as 'CodTipoCiclo'
	,TIP.TIPO_Desc1		as 'TipoCiclo'
	
	--curso
	--,cur.CURS_Nombre
	,CUR.CURS_Descripcion	 as Libro
	--,TI2.TIPO_Desc1
	--,TI2.TIPO_mascara
	
	--FASE - PROGRAMA
	--,T12.TIPO_TabFase
	,cur.TIPO_CodFase
	,TI2.TIPO_Desc1			AS Fase
	--,TI2.TIPO_Desc2
	--,TI2.TIPO_DescC
	
	--CARRERA
	,car.CARR_CodCarr
	,car.CARR_Nombre		AS Carrera		--SELECT * FROM CARRERAS
	,car.CARR_Descripcion	AS CarreraDesc
	
	--trabajadores
	,tra.TRAB_Cod			as PROF_codigo
	,tra.TRAB_Apellido1		as PROF_apellido
	,tra.TRAB_Nombre1		as PROF_nombre
	
	--pagos
	,TI3.TIPO_Desc1			AS Descuento
	,TI4.TIPO_Desc1			AS Concepto
	,dcp.DCOM_PrecioUni	
	,dcp.DCOM_ValorVta	
	,dcp.DCOM_Descuento	
	,DCOM_Otros
	,dcp.DCOM_Seguro
	,TI5.TIPO_Desc1			AS Beca
	,dcp.DCOM_FecCrea

FROM Matriculas	mat
	inner join clientes			CLI on cli.CLTE_CodCli		= mat.CLTE_CodCli			and cli.SUCR_CodSuc		= @Sede
	inner join ciclos			CIC on cic.cicl_codciclo	= mat.cicl_codciclo			and cic.SUCR_CodSuc		= @Sede		--and CICL_Estado = 'C'
	inner join cursosofrecidos	COF on cof.CROF_CodCurso	= mat.CROF_CodCurso			and cof.SUCR_CodSuc		= @Sede
	inner join tipos			TIP on tip.tipo_codtipo		= cic.TIPO_CCodTipoCiclo	and TIP.TIPO_CODTABLA	= cic.TIPO_TCodTipoCiclo		--tipo de ciclo REGULAR NIÑOS TECSUP TOEFL/BUSINESS/TOURISM
	inner join CURSOS			CUR ON CUR.CURS_CodCurso	= cof.CURS_CodCurso			and CUR.SUCR_CodSuc		= @Sede
	inner join salones			SAL ON SAL.salo_codsalon	= cof.salo_codsalon			and SAL.SUCR_CodSuc		= @Sede 
	inner join Horarios			HOR ON HOR.HORA_CodHora		= cof.HORA_CodHora			and HOR.SUCR_CodSuc		= @Sede
	left join Trabajadores		TRA	ON TRA.TRAB_COD			= cof.Trab_cod				and TRA.SUCR_CodSuc		= @Sede
	inner join carreras			CAR ON car.CARR_CodCarr		= cur.CARR_CodCarr			and CAR.SUCR_CodSuc		= @Sede
	inner join tipos			TI2 ON TI2.TIPO_CODTIPO		= cur.TIPO_CodFase			and TI2.TIPO_CODTABLA	= cur.TIPO_TabFase		--FASE
	inner join detcomppago		DCP ON DCP.MATR_NumMat		= mat.MATR_NumMat			and dcp.SUCR_CodSuc		= @Sede
	left join tipos				TI3 ON TI3.TIPO_CODTIPO		= dcp.TIPO_CCodTipoDscto	and TI3.TIPO_CODTABLA	= dcp.TIPO_TCodTipoDscto
	left join tipos				TI4 ON TI4.TIPO_CODTIPO		= dcp.TIPO_CCodConcep		and TI4.TIPO_CODTABLA	= dcp.TIPO_TCodConcep
	left join tipos				TI5 ON TI5.TIPO_CODTIPO		= dcp.TIPO_CodBeca			and TI5.TIPO_CODTABLA	= dcp.TIPO_TipoBeca

where 
	cof.CROF_CodCurso = @CodCROF
	--dateadd(day,15,cic.CICL_FecIniClass) > '2021-08-01'
	and mat.SUCR_CodSuc		= @Sede
	and mat.matr_estado		= 'C'
	--and mat.MATR_Aprobado	= 'A'
	/*and CROF_Nombre	in	(	 'B2_06'
							,'B2-06'
							,'B2_4_IN'
							,'B2-4-IN'
							,'NAIA6'--regular
							,'LIUIB24'--intensivo
							
	)*/
	/*
	and 
	TIP.TIPO_Desc1	not like '%niños%'
	*/
order by 
--mat.CLTE_CodCli,
mat.MATR_NumMat
--CLTE_Apellido
--,CLTE_Nombre

--car.CARR_CodCarr
,cic.cicl_codciclo desc
--,TIP.TIPO_Desc1			--fase
--,cic.cicl_codciclo
--,CICL_Descripcion
,cur.CURS_Descripcion		--libro
,CROF_Nombre
,TRAB_Apellido1
,CLTE_Apellido
,CLTE_Nombre
