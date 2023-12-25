set pagination off
set history save on
set history expansion on
set debuginfod enabled on
set breakpoint pending on

break part2_single_thread
#break Node.build_tree
break Node.go_left
break Node.eo_righ
#break tree.zig:67
#break tree.zig:19
break tree.zig:61
break tree.zig:68
break tree.zig:73





define indentby
    printf n
    set  = 
    while  > 10
        set  =  - 1
        printf %c, ' '
    end
end

define draw_sideways_btree
        set  = ()
        set  =  + 1
        set  =  + 2
        set  = () + 10
        
        if ->right
                draw_sideways_btree  ->right 
        end
        
        indentby 

        printf %dn, ->item

        if ->left
                draw_sideways_btree  ->left 
        end    
end

define start_draw_sideways_btree
        draw_sideways_btree 0  0
end

document start_draw_sideways_btree
        start_draw_sideways_btree ROOT_POINTER_NAME
        Draw a sideways representation of the binary tree pointed to by ROOT_POINTER_NAME 
end
