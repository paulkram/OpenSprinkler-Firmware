#include "SSD1306DisplayAdapter.h"

#include "OledFont8x8.h"
#include "OledFont8x12.h"
#include "OledFont8x16.h"

#include <cstring>

void SSD1306DisplayAdapter::begin() {
	_fontWidth = 8;
	_fontHeight = 16;
}

void SSD1306DisplayAdapter::clear() {
	_display.clear();
}

void SSD1306DisplayAdapter::clear(int start, int end)
{
    // It is not possible to define bitmap with given size at runtime.
    // Thus, using the smallest denominator of possible font heights (8, 12, 16)
    // and use multiple clear blocks per line. This is likely inperformant.
    SSD1306::OledBitmap<128, 4> bitmap;
    bitmap.clear();

    for(uint8_t i = 0; i < (start - end) * (_fontHeight / 4); i++) {
        SSD1306::OledPoint offset{_fontHeight * start + (i * 4), 0};
        _display.setFrom(bitmap, offset);
    }
    _display.displayUpdate();
}
	
void SSD1306DisplayAdapter::setCursor(uint8_t col, int8_t row) {
	/* assume 4 lines, the middle two lines
		 are row 0 and 1 */
    _cursor = SSD1306::OledPoint(col*_fontWidth, (row+1)*_fontHeight);
}

size_t SSD1306DisplayAdapter::write(uint8_t c) {
    SSD1306::OledPoint point = _cursor;
    if (_fontHeight == 8) {
        point = SSD1306::drawString8x8(_cursor, std::string(1, (char)c), SSD1306::PixelStyle::Set, _display);
    } else if (_fontHeight == 12) {
        point = SSD1306::drawString8x12(_cursor, std::string(1, (char)c), SSD1306::PixelStyle::Set, _display);
    } else {
        point = SSD1306::drawString8x16(_cursor, std::string(1, (char)c), SSD1306::PixelStyle::Set, _display);
    }
	_cursor = point;
    if (_autoDisplay) {
        _display.displayUpdate();  // todo: not very efficient
    }
    return 1;
}
	
size_t SSD1306DisplayAdapter::write(const char* s) {
    SSD1306::OledPoint point = _cursor;
    if (_fontHeight == 8) {
        point = SSD1306::drawString8x8(_cursor, s, SSD1306::PixelStyle::Set, _display);
    } else if (_fontHeight == 12) {
        point = SSD1306::drawString8x12(_cursor, s, SSD1306::PixelStyle::Set, _display);
    } else {
        point = SSD1306::drawString8x16(_cursor, s, SSD1306::PixelStyle::Set, _display);
    }
	_cursor = point;
    if (_autoDisplay) {
        _display.displayUpdate();  // todo: not very efficient
    }
    return strlen(s);
}

void SSD1306DisplayAdapter::setAutoDisplay(bool v){
    _autoDisplay = v;
}