//
//  PCFObject.h
//  
//
//  Created by DX123-XL on 2014-05-30.
//
//

#import <Foundation/Foundation.h>

typedef void (^PCFBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^PCFObjectResultBlock)(PFObject *object, NSError *error);

@interface PCFObject : NSObject

#pragma mark Constructors
///---------------------------
/// @name Creating a PCFObject
///---------------------------

/**
 Creates a new PCFObject with a class name.
 @param className A class name can be any alphanumeric string that begins with a letter. It represents an object in your app, like a User of a Document.
 @result Returns the object that is instantiated with the given class name.
 */
+ (instancetype)objectWithClassName:(NSString *)className;

/**
 Creates a new PCFObject with a class name, initialized with data constructed from the specified set of objects and keys.
 @param className The object's class.
 @param dictionary An NSDictionary of keys and objects to set on the new PCFObject.
 @result A PCFObject with the given class name and set with the given data.
 */
+ (instancetype)objectWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary;

/**
 Initializes a new PCFObject with a class name.
 @param newClassName A class name can be any alphanumeric string that begins with a letter. It represents an object in your app, like a User or a Document.
 @result Returns the object that is instantiated with the given class name.
 */
- (id)initWithClassName:(NSString *)newClassName;

#pragma mark -
#pragma mark Properties

///---------------------------------
/// @name Managing Object Properties
///---------------------------------

/**
 The class name of the object.
 */
@property (readonly) NSString *parseClassName;

/**
 The id of the object.
 */
@property (nonatomic, strong) NSString *objectID;


/**
 Returns an array of the keys contained in this object. This does not include
 createdAt, updatedAt, authData, or objectId. It does include things like username
 and ACL.
 */
- (NSArray *)allKeys;

#pragma mark -
#pragma mark Getters and Setters

/**
 Returns the object associated with a given key.
 @param key The key that the object is associated with.
 @result The value associated with the given key, or nil if no value is associated with key.
 */
- (id)objectForKey:(NSString *)key;

/**
 Sets the object associated with a given key.
 @param object The object.
 @param key The key.
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/**
 Unsets a key on the object.
 @param key The key.
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 * For myObject[key] = value type syntx myPCFObject[key].
 @param key The key.
 */
- (id)objectForKeyedSubscript:(NSString *)key;

/**
 * For myPCFObject[key] = value type syntx
 @param object The object.
 @param key The key.
 */
- (void)setObject:(id)object forKeyedSubscript:(NSString *)key;

#pragma mark -
#pragma mark Save

///--------------------------------------
/// @name Saving an Object to Data Server
///--------------------------------------

/**
 Saves the PCFObject and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the save succeeded.
 */
- (BOOL)save:(NSError **)error;

/**
 Saves the PCFObject asynchronously.
 */
- (void)saveInBackground;

/**
 Saves the PCFObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)saveInBackgroundWithBlock:(PCFBooleanResultBlock)block;

/**
 Saves the PCFObject asynchronously and calls the given callback.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
- (void)saveInBackgroundWithTarget:(id)target selector:(SEL)selector;

#pragma mark -
#pragma mark Refresh

/** @name Getting an Object from Parse */

/**
 Gets whether the PCFObject has been fetched.
 @result YES if the PCFObject is new or has been fetched or refreshed.  NO otherwise.
 */
- (BOOL)isDataAvailable;

/**
 Fetches the PCFObject with the current data from the server and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 */
- (void)fetch:(NSError **)error;

/**
 Fetches the PCFObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (PCFObject *object, NSError *error)
 */
- (void)fetchInBackgroundWithBlock:(PCFObjectResultBlock)block;

/**
 Fetches the PCFObject asynchronously and calls the given callback.
 @param target The target on which the selector will be called.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(PCFObject *)refreshedObject error:(NSError *)error. error will be nil on success and set if there was an error. refreshedObject will be the PCFObject with the refreshed data.
 */
- (void)fetchInBackgroundWithTarget:(id)target selector:(SEL)selector;

#pragma mark -
#pragma mark Delete

///------------------------------------------
/// @name Removing an Object from Data Server
///------------------------------------------

/**
 Deletes the PCFObject and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the delete succeeded.
 */
- (BOOL)delete:(NSError **)error;

/**
 Deletes the PCFObject asynchronously.
 */
- (void)deleteInBackground;

/**
 Deletes the PCFObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)deleteInBackgroundWithBlock:(PCFBooleanResultBlock)block;

/**
 Deletes the PCFObject asynchronously and calls the given callback.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
- (void)deleteInBackgroundWithTarget:(id)target
                            selector:(SEL)selector;

#pragma mark -
#pragma Dirt

/**
 Gets whether any key-value pair in this object (or its children) has been added/updated/removed and not saved yet.
 @result Returns whether this object has been altered and not saved yet.
 */
- (BOOL)isDirty;

@end