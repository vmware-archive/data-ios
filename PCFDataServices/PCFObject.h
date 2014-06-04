//
//  PCFObject.h
//  
//
//  Created by DX123-XL on 2014-05-30.
//
//

#import <Foundation/Foundation.h>

@class PCFObject;

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
 @param className A class name can be any alphanumeric string that begins with a letter. It represents an object in your app, like a User or a Document.
 @result Returns the object that is instantiated with the given class name.
 */
- (id)initWithClassName:(NSString *)className;

#pragma mark -
#pragma mark Properties

///---------------------------------
/// @name Managing Object Properties
///---------------------------------

/**
 The class name of the object.
 */
@property (readonly) NSString *className;

/**
 The ID of the object.
 */
@property (nonatomic, strong) NSString *objectID;


/**
 Returns an array of the keys contained in this object. This does not include objectID.
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
 Sets the objects and keys from the dictionary on the PCFObject at once
 @param dictionary The dictionary with keys and values
 */

- (void)setObjectsForKeysWithDictionary:(NSDictionary *)dictionary;

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
 Saves the PCFObject synchronously and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the save succeeded.
 */
- (BOOL)saveSynchronously:(NSError **)error;

/**
 Saves the PCFObject asynchronously and executes the given callback block.
 @param success The block to execute when the save operation is successful.
 @param failure The block to execute when the save operation fails.
 */
- (void)saveOnSuccess:(void (^)(void))success
              failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark Fetch

/** @name Getting an Object from Parse */

/**
 Fetches the PCFObject synchronously with the current data from the server and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 */
- (BOOL)fetchSynchronously:(NSError **)error;

/**
 Fetches the PCFObject asynchronously and executes the given callback block.
 @param success The block to execute when the fetch operation is successful.
 @param failure The block to execute when the fetch operation fails.
 */
- (void)fetchOnSuccess:(void (^)(PCFObject *object))success
               failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark Delete

///------------------------------------------
/// @name Removing an Object from Data Server
///------------------------------------------

/**
 Deletes the PCFObject synchronously and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the delete succeeded.
 */
- (BOOL)deleteSynchronously:(NSError **)error;

/**
 Deletes the PCFObject asynchronously and executes the given callback block.
 @param success The block to execute if the delete operation is successful.
 @param failure The block to execute if the delete operation fails.
 */
- (void)deleteOnSuccess:(void (^)(void))success
                failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma Dirtiness

/**
 Gets whether any key-value pair in this object (or its children) has been added/updated/removed and not saved yet.
 @result Returns whether this object has been altered and not saved yet.
 */
- (BOOL)isDirty;

@end