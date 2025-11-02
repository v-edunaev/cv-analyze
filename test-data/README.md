# Test Data

This folder contains sample CV files for testing the CV Analyzer application.

## File Types

### Valid Test Files
- **`valid-cv-sample.txt`** - Plain text CV with standard format
- **`valid-cv-sample.pdf`** - PDF version of a complete CV
- **`valid-cv-sample.docx`** - Microsoft Word document CV
- **`sample-cv.txt`** - Additional sample CV for testing

### Invalid Test Files
- **`invalid-cv-empty.txt`** - Empty file to test error handling
- **`invalid-cv-too-short.txt`** - Very short file that shouldn't pass validation
- **`invalid-cv-corrupted.txt`** - Corrupted/malformed content
- **`invalid-cv-corrupted.docx`** - Corrupted Word document

## Usage

These files are used for:
1. **Manual Testing** - Upload through the web interface
2. **Automated Testing** - Unit tests for CV processing
3. **CI/CD Pipeline** - Validation of file processing functionality
4. **Development** - Testing different file formats and edge cases

## File Format Support

The application supports:
- ✅ **PDF** - Extracted using PdfPig library
- ✅ **DOCX/DOC** - Extracted using DocumentFormat.OpenXml
- ✅ **TXT** - Direct text reading
- ❌ **Other formats** - Will be rejected with appropriate error messages