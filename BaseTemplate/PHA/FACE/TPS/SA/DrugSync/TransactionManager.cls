/// Transaction helper - valen MPF
Class PHA.FACE.TPS.SA.DrugSync.TransactionManager Extends %RegisteredObject
{

ClassMethod Start()
{
    TSTART
    quit
}

ClassMethod Commit()
{
    TCOMMIT
    quit
}

ClassMethod Rollback()
{
    TROLLBACK
    quit
}

}
