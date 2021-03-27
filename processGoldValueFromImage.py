import cv2
try:
    from PIL import Image
except ImportError:
    import Image
import pytesseract

originalImage = cv2.imread('goldValue.bmp')
grayImage = cv2.cvtColor(originalImage, cv2.COLOR_BGR2GRAY)
  
(thresh, blackAndWhiteImage) = cv2.threshold(grayImage, 127, 255, cv2.THRESH_BINARY)
 
# cv2.imshow('Black white image', blackAndWhiteImage)
#cv2.imshow('Original image',originalImage)
#cv2.imshow('Gray image', grayImage)
cv2.imwrite("goldValueProcessed.bmp", blackAndWhiteImage) 
  
#cv2.waitKey(0)

# If you don't have tesseract executable in your PATH, include the following:
#pytesseract.pytesseract.tesseract_cmd = r'<full_path_to_your_tesseract_executable>'
# Example tesseract_cmd = r'C:\Program Files (x86)\Tesseract-OCR\tesseract'
custom_config = '--oem 1 --psm 7 -c tessedit_char_whitelist=0123456789 digits'
#print(pytesseract.image_to_string(Image.open('goldValueProcessed.bmp'), config=custom_config))

goldValueByTess = pytesseract.image_to_string(Image.open('goldValueProcessed.bmp'), config=custom_config)

filename = "goldValue.txt"
writeGoldValue = open(filename, 'w')
writeGoldValue.write(goldValueByTess)
writeGoldValue.close()
