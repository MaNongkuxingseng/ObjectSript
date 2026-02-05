/// 调价业务公共方法
Class PHA.FACE.TPS.SA.INAsp.Com Extends PHA.COM.Data.Base
{

ClassMethod GetHosp4LocCode(locCode) As %String
{
	s dictResolver = ##class(PHA.FACE.TPS.SA.Template.Mapping.Resolver.DictResolver).%New()
	Set params = {"dictType": "HIS_LOC"}
	s locId = dictResolver.Resolve(locCode,params)
	s hospId = ..HospIdByLoc(locId)
	
	q hospId
}

}
