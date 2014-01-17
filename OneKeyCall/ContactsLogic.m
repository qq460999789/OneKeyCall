//
//  ContactsLogic.m
//  OneKeyCall
//
//  Created by swhl on 13-7-5.
//  Copyright (c) 2013年 sprite. All rights reserved.
//

#import "ContactsLogic.h"
#import "POAPinyin.h"

@implementation ContactsLogic

-(NSMutableDictionary*)loadContacts{
    NSMutableDictionary *contactsDictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    
    
    
    ABAddressBookRef addressBook = NULL;
    __block BOOL accessGranted = NO;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        addressBook = ABAddressBookCreateWithOptions(NULL, nil);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
        if (!accessGranted)
            addressBook = nil;
    } else { // we're on iOS 5 or older
        addressBook = ABAddressBookCreate();
    }
    
    
    
//        CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBook);//将通讯录中的信息用数组方式读出
//        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);//获取通讯录中联系人
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    CFIndex nPeople  = ABAddressBookGetPersonCount(addressBook);
    
//    NSLog(@"%ld",nPeople);
    NSArray* contactsArray =  ABAddressBookCopyArrayOfAllPeople(addressBook);
//    NSArray *contactsArray = (NSArray*)ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);
    contactsArray = [contactsArray sortedArrayUsingComparator:^NSComparisonResult(id person1, id person2) {
        NSString *first1 =(NSString *)ABRecordCopyValue(person1, kABPersonFirstNameProperty);
        NSString *last1 = (NSString *)ABRecordCopyValue(person1, kABPersonLastNameProperty);
        NSMutableString *name1 = [[[NSMutableString alloc]initWithCapacity:0]autorelease];
        if (last1)
            [name1 appendString:last1];
        if(first1)
            [name1 appendString:first1];
        name1 = (NSMutableString*)[POAPinyin quickConvert:name1];
        
        NSString *first2 =(NSString *)ABRecordCopyValue(person2, kABPersonFirstNameProperty);
        NSString *last2 = (NSString *)ABRecordCopyValue(person2, kABPersonLastNameProperty);
        NSMutableString *name2 = [[[NSMutableString alloc]initWithCapacity:0]autorelease];
        if (last2)
            [name2 appendString:last2];
        if(first2)
            [name2 appendString:first2];
         name2 = (NSMutableString*)[POAPinyin quickConvert:name2];
        
         return [name1 caseInsensitiveCompare:name2];
        
    }];
    
    

    
   
    
    for (int i = 0; i < contactsArray.count; i++)
    {
        ABRecordRef person = contactsArray[i];//取出某一个人的信息
        
        
        NSString *first =(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *last = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
   
        
        
        
        NSMutableString *name = [[[NSMutableString alloc]initWithCapacity:0]autorelease];
        if (last)
            [name appendString:last];
        if(first)
            [name appendString:first];
        
        NSString *groupIndex = @"";
        if(name.length>0&&[ComMethod isValidateCHAndChar:[name substringToIndex:1]]){
            groupIndex = [[POAPinyin quickConvert:name] substringToIndex:1];
        }else{
            groupIndex = @"#";
        }

        NSMutableArray *array = contactsDictionary[groupIndex];
        if(!array){
            array = [[NSMutableArray alloc]initWithCapacity:0];
            contactsDictionary[groupIndex] = array;
            [array release];
        }
        
        [array addObject:person];

//        NSLog(@"g=%@---all=%@",groupIndex,name);
       
    }
//     NSLog(@"%@",contactsDictionary);

    return [contactsDictionary autorelease];
}


@end
