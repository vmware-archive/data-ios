//
//  MSSObject.h
//  
//
//  Created by DX123-XL on 2014-05-30.
//
//

#import <Foundation/Foundation.h>

@class MSSObject;

@interface MSSObject : NSObject

#pragma mark Constructors
///---------------------------
/// @name Creating a MSSObject
///---------------------------

/**
 Creates a new MSSObject with a class name.
 @param className A class name can be any alphanumeric string that begins with a letter. It represents an object in your app, like a User of a Document.
 @result Returns the object that is instantiated with the given class name.
 */
+ (instancetype)objectWithClassName:(NSString *)className;

/**
 Creates a new MSSObject with a class name, initialized with data constructed from the specified set of objects and keys.
 @param className The object's class.
 @param dictionary An NSDictionary of keys and objects to set on the new MSSObject.
 @result A MSSObject with the given class name and set with the given data.
 */
+ (instancetype)objectWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary;

/**
 Initializes a new MSSObject with a class name.
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
 Sets the objects and keys from the dictionary on the MSSObject at once
 @param dictionary The dictionary with keys and values
 */

- (void)setObjectsForKeysWithDictionary:(NSDictionary *)dictionary;

/**
 Unsets a key on the object.
 @param key The key.
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 * For myObject[key] = value type syntx myMSSObject[key].
 @param key The key.
 */
- (id)objectForKeyedSubscript:(NSString *)key;

/**
 * For myMSSObject[key] = value type syntx
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
 Saves the MSSObject asynchronously and executes the given callback block.
 @param success The block to execute when the save operation is successful.
 @param failure The block to execute when the save operation fails.
 */
- (void)saveOnSuccess:(void (^)(MSSObject *object))success
              failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark Fetch

/** @name Getting an Object from Parse */

/**
 Fetches the MSSObject asynchronously and executes the given callback block.
 @param success The block to execute when the fetch operation is successful.
 @param failure The block to execute when the fetch operation fails.
 */
- (void)fetchOnSuccess:(void (^)(MSSObject *object))success
               failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark Delete

///------------------------------------------
/// @name Removing an Object from Data Server
///------------------------------------------

/**
 Deletes the MSSObject asynchronously and executes the given callback block.
 @param success The block to execute if the delete operation is successful.
 @param failure The block to execute if the delete operation fails.
 */
- (void)deleteOnSuccess:(void (^)(MSSObject *object))success
                failure:(void (^)(NSError *error))failure;

@end