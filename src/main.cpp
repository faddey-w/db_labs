#include <iostream>
#include "DB.h"

int main() {

    try{
        Database("donnu_db_labs");
    } catch (const DatabaseError& err) {
        std::cout << err.what() << " -> " << err.err_code << std::endl; 
    }
    return 0;
}
