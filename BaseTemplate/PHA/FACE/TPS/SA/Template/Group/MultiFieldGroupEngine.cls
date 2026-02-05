Class PHA.FACE.TPS.SA.Template.Group.MultiFieldGroupEngine Extends %RegisteredObject
{

ClassMethod Group(list As %ListOfObjects, fields As %ListOfDataTypes) As %DynamicObject
{
    Set result = ##class(%DynamicObject).%New()

    For i=1:1:list.Count() {
        Set item = list.GetAt(i) ; DynamicObject
        Set key = ""

        For j=1:1:fields.Count() {
            Set fname = fields.GetAt(j)
            Set value = ""
            If item.%IsDefined(fname) {
                Set value = item.%Get(fname)
            }
            If j=1 Set key=value
		    Else  Set key=key_"|"_value
        }
        
        If 'result.%IsDefined(key) {
            Set arr = ##class(%DynamicArray).%New()
            Do result.%Set(key, arr)
        } Else {
            Set arr = result.%Get(key)
        }

        Do arr.%Push(item)
    }

    Quit result
}

}
