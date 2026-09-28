({
    handleUploadFinished : function(cmp, event, helper) {  
        var uploadedFileNames='';
        //Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        uploadedFiles.forEach(function(file){
            if(uploadedFileNames==''){
                uploadedFileNames = file.name;  
            }else{
                uploadedFileNames = uploadedFileNames + ',' + file.name; 
            }
        });
        //Show success message – with no of files uploaded
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : "success",
            "message": uploadedFiles.length+" files has been uploaded successfully!"
        });
        toastEvent.fire();
        helper.getUploadedFiles(cmp, event); 
        helper.createCaseCommentRecord(cmp, event,uploadedFileNames);
    }
})