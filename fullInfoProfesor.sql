/*******************************************/
USE CCPNA;
DECLARE @CodProf	varchar(6);
DECLARE @Sede varchar(2);
DECLARE @Nombre varchar(50);
DECLARE @Apellido varchar(50);
SET @Sede		= '01';
SET @CodProf	= '07362';
SET @Nombre		= '%ka%';
SET @Apellido	= '%flores%';


/*******************************************/

--SELECT top 100 TRAB_Nombre1,TRAB_Apellido1,TRAB_Apellido2, * FROM trabajadores WHERE	TRAB_Nombre1 like @Nombre and TRAB_Apellido1 like @Apellido;

SELECT 
	tra.SUCR_CodSuc
	,TRA.TRAB_Cod
	,TRA.TRAB_Nombre1
	,TRA.TRAB_Apellido1 
	
	--CARRERA
	,car.CARR_CodCarr
	,car.CARR_Nombre		AS Carrera

	--ciclos
	,tip.TIPO_Desc1 as tipoCiclo
	,cic.cicl_codciclo
	,cic.CICL_Descripcion
	
	--fase
	--,CUR.TIPO_TabFase
	--,CUR.TIPO_CodFase
	,t02.TIPO_Desc1		AS Fase
	
	--cursos
	,CUR.CURS_Nombre
	,CUR.CURS_Descripcion
	
	--cursofrecido
	,cof.CROF_CodCurso
	,cof.CROF_Nombre
	,cof.CROF_Estado
	,cof.CROF_FecInicio
	
	--salones
	--SELECT * FROM salones
	,sal.SALO_CodSalon
	,sal.SALO_Descripcion
	,sal.SALO_Ubicacion

	--horarios
	,hor.HORA_CodHora
	,HOR.HORA_Inicio
	,HOR.HORA_Fin
	
FROM		dbo.CursosOfrecidos	cof
INNER JOIN	dbo.Trabajadores 	TRA	ON TRA.TRAB_COD			= cof.Trab_cod				AND TRA.[SUCR_CodSuc]	= @Sede
INNER JOIN	dbo.Cursos			cur ON  CUR.CURS_CodCurso	= cof.CURS_CodCurso			AND CUR.[SUCR_CodSuc]	= @Sede	 
INNER JOIN	TIPOS				T02	ON T02.TIPO_CODTIPO		= cur.TIPO_CodFase			AND T02.TIPO_CODTABLA	= cur.TIPO_TabFase
INNER JOIN	dbo.Carreras		car ON  car.CARR_CodCarr	= cur.CARR_CodCarr			AND CAR.[SUCR_CodSuc]	= @Sede
INNER JOIN	dbo.Ciclos			cic ON  cic.[cicl_codciclo]	= cof.[cicl_codciclo]		and cic.[SUCR_CodSuc]	= @Sede		--and CICL_Estado = 'C'
INNER JOIN	dbo.Salones			sal ON SAL.salo_codsalon	= cof.salo_codsalon			AND SAL.[SUCR_CodSuc]	= @Sede
INNER JOIN	dbo.Horarios		HOR ON HOR.HORA_CodHora		= cof.HORA_CodHora			AND HOR.[SUCR_CodSuc]	= @Sede
INNER JOIN	dbo.Tipos 			tip ON  tip.tipo_codtipo	= cic.TIPO_CCodTipoCiclo	AND TIP.TIPO_CODTABLA	= cic.TIPO_TCodTipoCiclo
WHERE	cof.TRAB_Cod	= @CodProf			and cof.[SUCR_CodSuc]	= @Sede
ORDER BY 
	cic.cicl_codciclo desc
	,cof.CROF_CodCurso desc
