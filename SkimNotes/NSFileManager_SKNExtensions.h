//
//  NSFileManager_SKNExtensions.h
//  SkimNotes
//
//  Created by Christiaan Hofman on 6/15/08.
/*
 This software is Copyright (c) 2008
 Christiaan Hofman. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

 - Neither the name of Christiaan Hofman nor the names of any
    contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*!
    @header      
    @abstract    An <code>NSFileManager</code> category to read and write Skim notes.
    @discussion  This header file provides API for an <code>NSFileManager</code> category to read and write Skim notes.
*/
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @enum        SKNSkimNotesWritingOptions
 @abstract    Options for writing Skim notes.
 @discussion  These options can be passed to the main methods for writing Skim notes to extended attributes or to file.
 @constant    SKNSkimNotesWritingPlist      Write plist data rather than archived data.  Always implied on iOS.
 @constant    SKNSkimNotesWritingSyncable   Hint to add a syncable flag to the attribute names if available, when writing to extended attributes.
 */
enum {
    SKNSkimNotesWritingPlist = 1 << 0,
    SKNSkimNotesWritingSyncable = 1 << 1
};
typedef NSInteger SKNSkimNotesWritingOptions;

/*!
    @abstract    Provides methods to access Skim notes in extended attributes or PDF bundles.
    @discussion  This category is the main interface to read and write Skim notes from and to files and extended attributes of files.
*/
@interface NSFileManager (SKNExtensions)

/*!
    @abstract   Reads Skim notes as an array of property dictionaries from the extended attributes of a file.
    @discussion Reads the data from the extended attributes of the file and convert.
    @param      aURL The URL for the file to read the Skim notes from.
    @param      outError If there is an error reading the Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     An array of dictionaries with Skim note properties, an empty array if no Skim notes were found, or <code>nil</code> if there was an error reading the Skim notes.
*/
- (nullable NSArray<NSDictionary<NSString *, id> *> *)readSkimNotesFromExtendedAttributesAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Reads text Skim notes as a string from the extended attributes of a file.
    @discussion Reads the data from the extended attributes of the file and unarchives it using <code>NSKeyedUnarchiver</code>.
    @param      aURL The URL for the file to read the text Skim notes from.
    @param      outError If there is an error reading the text Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     A string representation of the Skim notes, an empty string if no text Skim notes were found, or <code>nil</code> if there was an error reading the text Skim notes.
*/
- (nullable NSString *)readSkimTextNotesFromExtendedAttributesAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Reads rich text Skim notes as RTF data from the extended attributes of a file.
    @discussion Reads the data from the extended attributes of the file.
    @param      aURL The URL for the file to read the RTF Skim notes from.
    @param      outError If there is an error reading the RTF Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     <code>NSData</code> for an RTF representation of the Skim notes, an empty <code>NSData</code> object if no RTF Skim notes were found, or <code>nil</code> if there was an error reading the RTF Skim notes.
*/
- (nullable NSData *)readSkimRTFNotesFromExtendedAttributesAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Reads Skim notes as an array of property dictionaries from the contents of a PDF bundle.
    @discussion Reads the data from a bundled file in the PDF bundle with the proper .skim extension.
    @param      aURL The URL for the PDF bundle to read the Skim notes from.
    @param      outError If there is an error reading the Skim notes, upon return contains an NSError object that describes the problem.
    @result     An array of dictionaries with Skim note properties, an empty array if no Skim notes were found, or <code>nil</code> if there was an error reading the Skim notes.
*/
- (nullable NSArray<NSDictionary<NSString *, id> *> *)readSkimNotesFromPDFBundleAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Reads text Skim notes as a string from the contents of a PDF bundle.
    @discussion Reads the data from a bundled file in the PDF bundle with the proper .txt extension.
    @param      aURL The URL for the PDF bundle to read the text Skim notes from.
    @param      outError If there is an error reading the text Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     A string representation of the Skim notes, an empty string if no text Skim notes were found, or <code>nil</code> if there was an error reading the text Skim notes.
*/
- (nullable NSString *)readSkimTextNotesFromPDFBundleAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Reads rich text Skim notes as RTF data from the contents of a PDF bundle.
    @discussion Reads the data from a bundled file in the PDF bundle with the proper .rtf extension.
    @param      aURL The URL for the PDF bundle to read the RTF Skim notes from.
    @param      outError If there is an error reading the RTF Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     <code>NSData</code> for an RTF representation of the Skim notes, an empty <code>NSData</code> object if no RTF Skim notes were found, or <code>nil</code> if there was an error reading the RTF Skim notes.
*/
- (nullable NSData *)readSkimRTFNotesFromPDFBundleAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Reads Skim notes as an array of property dictionaries from the contents of a .skim file.
    @discussion Reads data from the file and unarchives it using NSKeyedUnarchiver.
    @param      aURL The URL for the .skim file to read the Skim notes from.
    @param      outError If there is an error reading the Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     An array of dictionaries with Skim note properties, an empty array if no Skim notes were found, or <code>nil</code> if there was an error reading the Skim notes.
*/
- (nullable NSArray<NSDictionary<NSString *, id> *> *)readSkimNotesFromSkimFileAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Writes Skim notes passed as an array of property dictionaries to the extended attributes of a file, as well as a defaultrepresentation for text Skim notes and RTF Skim notes.
 @discussion Calls <code>writeSkimNotes:textNotes:richTextNotes:toExtendedAttributesAtURL:options:error:</code> with nil <code>notesString</code> and <code>notesRTFData</code> and the <code>SKNSkimNotesWritingPlist<code> and <code>SKNSkimNotesWritingSyncable<code> options.
    @param      notes An array of dictionaries containing Skim note properties, as returned by the properties of a PDFAnnotation.
    @param      aURL The URL for the file to write the Skim notes to.
    @param      outError If there is an error writing the Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     Returns <code>YES</code> if writing out the Skim notes was successful; otherwise returns <code>NO</code>.
*/
- (BOOL)writeSkimNotes:(nullable NSArray<NSDictionary<NSString *, id> *> *)notes toExtendedAttributesAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Writes Skim notes passed as an array of property dictionaries to the extended attributes of a file, as well as text Skim notes and RTF Skim notes.  The array is converted to <code>NSData</code> using <code>NSKeyedArchiver</code>.
 @discussion Calls <code>writeSkimNotes:textNotes:richTextNotes:toExtendedAttributesAtURL:options:error:</code> with the <code>SKNSkimNotesWritingPlist<code> and <code>SKNSkimNotesWritingSyncable<code> options.
    @param      notes An array of dictionaries containing Skim note properties, as returned by the properties of a <code>PDFAnnotation</code>.
    @param      notesString A text representation of the Skim notes.  When <code>nil</code>, a default representation will be generated from notes.
    @param      notesRTFData An RTF data representation of the Skim notes.  When <code>nil</code>, a default representation will be generated from notes.
    @param      aURL The URL for the file to write the Skim notes to.
    @param      outError If there is an error writing the Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     Returns <code>YES</code> if writing out the Skim notes was successful; otherwise returns <code>NO</code>.
*/
- (BOOL)writeSkimNotes:(nullable NSArray<NSDictionary<NSString *, id> *> *)notes textNotes:(nullable NSString *)notesString richTextNotes:(nullable NSData *)notesRTFData toExtendedAttributesAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
 @abstract   Writes Skim notes passed as an array of property dictionaries to the extended attributes of a file, as well as text Skim notes and RTF Skim notes.  The array is converted to <code>NSData</code> using <code>NSKeyedArchiver</code> or as plist data, depending on the options.
 @discussion This writes three types of Skim notes to the extended attributes to the file located through <code>aURL</code>.
 @param      notes An array of dictionaries containing Skim note properties, as returned by the properties of a <code>PDFAnnotation</code>.
 @param      notesString A text representation of the Skim notes.  When <code>nil</code>, a default representation will be generated from notes.
 @param      notesRTFData An RTF data representation of the Skim notes.  When <code>nil</code>, a default representation will be generated from notes.
 @param      aURL The URL for the file to write the Skim notes to.
 @param      options The write options to use.
 @param      outError If there is an error writing the Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
 @result     Returns <code>YES</code> if writing out the Skim notes was successful; otherwise returns <code>NO</code>.
 */
- (BOOL)writeSkimNotes:(nullable NSArray<NSDictionary<NSString *, id> *> *)notes textNotes:(nullable NSString *)notesString richTextNotes:(nullable NSData *)notesRTFData toExtendedAttributesAtURL:(NSURL *)aURL options:(SKNSkimNotesWritingOptions)options error:(NSError **)outError;

/*!
    @abstract   Writes Skim notes passed as an array of property dictionaries to a .skim file.
    @discussion Calls <code>writeSkimNotes:toSkimFileAtURL:options:error:</code> with the <code>SKNSkimNotesWritingPlist<code> options.
    @param      notes An array of dictionaries containing Skim note properties, as returned by the properties of a <code>PDFAnnotation</code>.
    @param      aURL The URL for the .skim file to write the Skim notes to.
    @param      outError If there is an error writing the Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     Returns <code>YES</code> if writing out the Skim notes was successful; otherwise returns <code>NO</code>.
*/
- (BOOL)writeSkimNotes:(nullable NSArray<NSDictionary<NSString *, id> *> *)notes toSkimFileAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Writes Skim notes passed as an array of property dictionaries to a .skim file.  The array is converted to <code>NSData</code> using <code>NSKeyedArchiver</code> or as plist data, depending on the options.
    @discussion Writes the data to the file located by <code>aURL</code>.
    @param      notes An array of dictionaries containing Skim note properties, as returned by the properties of a <code>PDFAnnotation</code>.
    @param      aURL The URL for the .skim file to write the Skim notes to.
    @param      options The write options to use.
    @param      outError If there is an error writing the Skim notes, upon return contains an <code>NSError</code> object that describes the problem.
    @result     Returns <code>YES</code> if writing out the Skim notes was successful; otherwise returns <code>NO</code>.
*/
- (BOOL)writeSkimNotes:(nullable NSArray<NSDictionary<NSString *, id> *> *)notes toSkimFileAtURL:(NSURL *)aURL options:(SKNSkimNotesWritingOptions)options error:(NSError **)outError;

/*!
    @abstract   Returns the file URL for the file of a given type inside a PDF bundle.
    @discussion If more than one bundled files with the given extension exist in the PDF bundle, this will follow the naming rules followed by Skim to find the best match.
    @param      extension The file extension for which to find a bundled file.
    @param      aURL The URL to the PDF bundle.
    @param      outError If there is an error getting the bundled file, upon return contains an <code>NSError</code> object that describes the problem.
    @result     A file URL to the bundled file inside the PDF bundle, or <code>nil</code> if no bundled file was found.
*/
- (nullable NSURL *)bundledFileURLWithExtension:(NSString *)extension inPDFBundleAtURL:(NSURL *)aURL error:(NSError **)outError;

/*!
    @abstract   Returns the full path for the file of a given type inside a PDF bundle.
    @discussion If more than one bundled files with the given extension exist in the PDF bundle, this will follow the naming rules followed by Skim to find the best match. This method is deprecated.
    @param      extension The file extension for which to find a bundled file.
    @param      path The path to the PDF bundle.
    @param      outError If there is an error getting the bundled file, upon return contains an <code>NSError</code> object that describes the problem.
    @result     A full path to the bundled file inside the PDF bundle, or <code>nil</code> if no bundled file was found.
*/
- (nullable NSString *)bundledFileWithExtension:(NSString *)extension inPDFBundleAtPath:(NSString *)path error:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
