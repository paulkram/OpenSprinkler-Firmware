#pragma once

#include "defines.h"

#include "OledI2C.h"

#include <cstdint>
#include <string>

const uint8_t LCD_I2C = 1;

class SSD1306DisplayAdapter
{
public:
    SSD1306DisplayAdapter(const std::string& device, uint8_t address)
        : _display(device, address), _fontHeight(16), _fontWidth(8), _cursor(0,0), _autoDisplay(true)
        {}

    void begin();
	void clear();
	void clear(int start, int end);

	uint8_t type() { return LCD_I2C; }
	void setCursor(uint8_t col, int8_t row);
    
	size_t write(uint8_t c);
	size_t write(const char* s);
	void createChar(byte idx, PGM_P ptr) {}
    
	void setAutoDisplay(bool v);

private:
    SSD1306::OledI2C _display;
    uint8_t _fontHeight;
    uint8_t _fontWidth;
    SSD1306::OledPoint _cursor;
    bool _autoDisplay;
};