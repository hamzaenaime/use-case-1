import { LightningElement, wire, api } from "lwc";
import Category__c from "@salesforce/schema/Movie__c.Category__c";
import Movie__c from "@salesforce/schema/Movie__c";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";

export default class GetMoviesCategories extends LightningElement {
  @wire(getObjectInfo, { objectApiName: Movie__c }) movieMetaData;

  picklistValues;
  @wire(
    getPicklistValues,

    {
      recordTypeId: "$movieMetaData.data.defaultRecordTypeId",

      fieldApiName: Category__c
    }
  )
  setCategoryPicklistOptions({ error, data }) {
    if (data) {
      this.picklistValues = data.values;
    } else if (error) {
      console.log(error);
    }
  }
  getValues() {
    return "hello";
  }
}
