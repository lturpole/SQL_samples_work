
/*******************************************/
USE CCPNA_TAC;
DECLARE @Sede varchar(2);
SET @Sede		= '02';
/*******************************************/


SELECT
/*******************************************/
/*PARA REPORTES DE ALUMNOS*/
/*******************************************/

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
	
	--datos personales
	,FLOOR((CAST (GetDate() AS INTEGER) - CAST(CLTE_FecNac AS INTEGER)) / 365.25) AS Edad
	,cli.CLTE_DocIden
	,cli.CLTE_EMail
	--,isnull(cli.CLTE_Tel1,'')				CLTE_Tel1
	,case isnull(cli.[CLTE_Tel1],'')		when '0' then '' else isnull(cli.[CLTE_Tel1],'')		end as CLTE_Tel1
	--,isnull(cli.[CLTE_Tel2],'')				CLTE_Tel2
	,case isnull(cli.[CLTE_Tel2],'')		when '0' then '' else isnull(cli.[CLTE_Tel2],'')		end as CLTE_Tel2
	--,isnull(cli.[CLTE_Celular],'')			CLTE_Celular
	,case isnull(cli.[CLTE_Celular],'')		when '0' then '' else isnull(cli.[CLTE_Celular],'')		end as CLTE_Celular
	--,isnull(cli.[CLTE_TelOfPadre],'')		CLTE_TelOfPadre
	,case isnull(cli.[CLTE_TelOfPadre],'')	when '0' then '' else isnull(cli.[CLTE_TelOfPadre],'')	end as CLTE_TelOfPadre
	--,isnull(cli.[CLTE_TelCelPadre],'')		CLTE_TelCelPadre
	,case isnull(cli.[CLTE_TelCelPadre],'')	when '0' then '' else isnull(cli.[CLTE_TelCelPadre],'')	end as CLTE_TelCelPadre
	--,isnull(cli.[CLTE_TelOfMadre],'')		CLTE_TelOfMadre
	,case isnull(cli.[CLTE_TelOfMadre],'')	when '0' then '' else isnull(cli.[CLTE_TelOfMadre],'')	end as CLTE_TelOfMadre
	--,isnull(cli.[CLTE_TelCelMadre],'')		CLTE_TelCelMadre
	,case isnull(cli.[CLTE_TelCelMadre],'')	when '0' then '' else isnull(cli.[CLTE_TelCelMadre],'')	end as CLTE_TelCelMadre
	--,isnull(cli.[CLTE_TelContacEmerg],'')	CLTE_TelContacEmerg
	,case isnull(cli.[CLTE_TelContacEmerg],'')	when '0' then '' else isnull(cli.[CLTE_TelContacEmerg],'')	end as CLTE_TelContacEmerg
	--,isnull(cli.[CLTE_CelContacEmerg],'')	CLTE_CelContacEmerg
	,case isnull(cli.[CLTE_CelContacEmerg],'')	when '0' then '' else isnull(cli.[CLTE_CelContacEmerg],'')	end as CLTE_CelContacEmerg
	
	
	--MATRICULA
	--,mat.MATR_NotaFinal		as nota
	--,mat.MATR_Aprobado		as Aprobado
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
	--inner join detcomppago		DCP ON DCP.MATR_NumMat		= mat.MATR_NumMat			and dcp.SUCR_CodSuc		= @Sede
	--left join tipos				TI3 ON TI3.TIPO_CODTIPO		= dcp.TIPO_CCodTipoDscto	and TI3.TIPO_CODTABLA	= dcp.TIPO_TCodTipoDscto
	--left join tipos				TI4 ON TI4.TIPO_CODTIPO		= dcp.TIPO_CCodConcep		and TI4.TIPO_CODTABLA	= dcp.TIPO_TCodConcep
	--left join tipos				TI5 ON TI5.TIPO_CODTIPO		= dcp.TIPO_CodBeca			and TI5.TIPO_CODTABLA	= dcp.TIPO_TipoBeca

where 
	year(dateadd(day,15,cic.CICL_FecIniClass))		= year(getdate())
	and month(dateadd(day,15,cic.CICL_FecIniClass))	= month(getdate())
	and mat.SUCR_CodSuc		= @Sede
	and mat.matr_estado		= 'C'
order by 
	cic.cicl_codciclo
	,cur.CURS_Descripcion		--libro
	,CROF_Nombre
	,TRAB_Apellido1
	,CLTE_Apellido
	,CLTE_Nombre