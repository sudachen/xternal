
#include <iostream>
#include "../include/libconf.h"

int main()
{
	libconf::Xnode r = libconf::New;
	libconf::Xnode n1 = r.Append("subnode1");
	n1["attr_hello"] = "hello";
	n1["attr_1"] = 1;
	n1["attr_0_25"] = 0.25;
	n1["attr_b"] = foobar::False;
	if ( !n1["attr_b"] )  { n1["attr_b"] = foobar::True; }
	if ( n1["attr_b"] )   { n1["attr_c"] = foobar::False; }
	std::string a = r.Format();
	std::cout << a << std::endl;
}

