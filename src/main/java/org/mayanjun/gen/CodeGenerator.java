package org.mayanjun.gen;

import org.springframework.core.Ordered;

public interface CodeGenerator extends Ordered {

    void generate();

}
