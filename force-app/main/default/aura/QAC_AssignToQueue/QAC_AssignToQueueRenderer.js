({
    render: function(component, helper) 
    {
        var ret = this.superRender();
        console.log('inside render');
        helper.refreshCurrentUtility(component);
        return ret;
    }
})