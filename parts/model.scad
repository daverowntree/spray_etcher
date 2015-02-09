// Instructables 'etchinator' derived PCB rotary spray etcher
// See: http://www.instructables.com/id/The-Etchinator-low-cost-spray-etcher/
// for the original design
//
// This code expands the design to make it possible to construct from easy to find parts
// and use 3D printed plastics for all other parts.  This makes it very customisable
// 
// Designer: Dave Rowntree (dave@davidrowntree.co.uk)
// Project home: https://github.com/daverowntree/spray_etcher
//
// V0.1: Initial version
//
// This project is part of the PCB rapid prototyping project hosted by So Make It (Southampton Makerspace: somakeit.org.uk)
// 
// Open Source License:  Creative Commons - Attribution Non-commercial Share Alike (by-nc-sa)
// Please see http://creativecommons.org/licenses/by-nc-sa/2.5/



// Globals
fine=50;

// Base model
base_width=150;
base_depth=120;
base_height=5;

// Tube model
tube_od = 34.6; // Outer diameter measured elliptic: 34.3/34.6
tube_th = 2.1;  // Wall thickness measured
tube_len = 50;

// Positioning
tube_offsetx=40;
tube_offsety=0;
tube_posz=-base_height/2;
tube_clearance=5;

// Impeller
impeller_h=8;
impeller_od=tube_od-2*tube_th;
impeller_ring_th=1.2;
impeller_lip_hole_d=20;
impeller_lip_th=1.2;
impeller_pivot_h=0.9;
impeller_pivot_od=2;

// Baffles
baffle_width=10;
baffle_depth=5;
baffle_th=1;
//baffle_id=10;
baffle_base_th=1;
baffle_web_th=2;
baffle_clearance=0.2;

// Impeller blades
blade_width=impeller_od;
blade_depth=impeller_h*2;
blade_th=1;

// Catcher model
catcher_d=2;
catcher_th=1;

// Top Cap
cap_height=10;
cap_od=tube_od+tube_th;
cap_overlap=5;

// Drains
slot_width=5;
slot_depth=40;
slot_height=20;

//////////////////////////////////////////////
// B O D Y
// Top level config;  explore: set to true, to show an exploded, rather than assmebled view
//
body(explode=true, platter=true);
/////////////////////////////////////////////


module body(explode=false, platter=false){
    
    if (platter){
        // Assemble on a platter, orientated for printing
        // They are all currently at different Z heights, but any slicer worth using
        // will be able to drop them down to z=0 automatically...
        translate([-tube_od,0,0]) baffle();
        translate([tube_od,tube_od*0.75,0]) rotate([180,0,0]) cap();
        translate([tube_od,-tube_od*0.75,0]) impeller();
        translate([-tube_od*1.5,-tube_od,0]) rotate ([90,0,90]) catcher();
        translate([-tube_od*1.5,-tube_od-5,0]) rotate ([90,0,90]) catcher();
        translate([-tube_od*1.5,-tube_od-10,0]) rotate ([90,0,90]) catcher();
        
        
    } else {
        // Assemble as per application
        // Set explode=false to show assembled, else true to show exploded assembly view
        base();
        translate([-tube_offsetx,tube_offsety,tube_posz]) spray_tube(explode);
        translate([-tube_offsetx,tube_offsety,explode ? -30 : -5]) baffle();
        translate([tube_offsetx,tube_offsety,tube_posz]) spray_tube(explode);
        translate([tube_offsetx,tube_offsety,explode ? -30 : -5]) baffle();
    }
}


/////////////////////////////////////////////
// B A S E
/////////////////////////////////////////////
module base(){

    // Cutouts
    difference(){
        cube([base_width,base_depth,base_height], center=true);
        base_cutouts();
    }
}

module base_cutouts(){
    translate([-tube_offsetx, tube_offsety, -5]) cylinder(h=      base_height+5, r=(tube_od+tube_clearance)/2,$fn=fine);
    translate([tube_offsetx, tube_offsety, -5])  cylinder(h=base_height+5, r=(tube_od+tube_clearance)/2,$fn=fine);

    // drain slots
    translate([0,0,0]) cube([slot_width,slot_depth,slot_height], center=true);
}


/////////////////////////////////////////////
// S P R A Y  T U B E
/////////////////////////////////////////////
module spray_tube(explode=true){

    %tube();

    translate([0,0,explode ? tube_len+cap_height*1.5 : tube_len]) cap();

    // catchers
    translate([0,0,0]){
        translate([-(tube_od-tube_th*2)/2,0,0]) catcher();
        rotate(120) translate([-(tube_od-tube_th*2)/2,0,0]) catcher();
        rotate(-120) translate([-(tube_od-tube_th*2)/2,0,0]) catcher();
    }

    translate([0,0,explode ? -blade_depth*0.75 : impeller_h]) impeller();
}

module tube(){
    difference(){
        cylinder(h=tube_len,r=tube_od/2,$fn=fine);
        translate([0,0,-5]) cylinder(h=tube_len+10,r=(tube_od-tube_th)/2,$fn=fine);
    }
}


//////////////////////////////////
// C a p   (Motor drive + top seal)
//////////////////////////////////
module cap(){

    difference(){
        cylinder(h=cap_height, r=cap_od/2, $fn=fine);
        translate([0,0,-(cap_height/2)-cap_overlap]) cap_remove_material();
    }
}

module cap_remove_material(){
    union(){
        difference(){
            cylinder(h=cap_height*1.5,r=tube_od/2,$fn=fine);
            translate([0,0,-5]) cylinder(h=tube_len+10,r=(tube_od-tube_th)/2,$fn=fine);
        }

        translate([0,0,cap_height*0.25]) cylinder(h=cap_height*1.5, r=(tube_od-tube_th*2)/2, $fn=fine);
    }
}

//////////////////////////////////
// I m p e l l e r
//////////////////////////////////
module impeller(){
    rotate([180,0,0]){
        color("green") impeller_ring();
        color("blue") impeller_blades();
        color("red") translate([0,0,blade_depth/2-impeller_lip_th]) impeller_lip();
    }
}

module impeller_ring(){
    //translate([0,0,-impeller_h/2]){
    translate([0,0,0]){
        difference(){
            cylinder(h=impeller_h, r=impeller_od/2,$fn=fine);
            translate([0,0,-2]) cylinder(h=impeller_h+5, r=impeller_od/2-impeller_ring_th,$fn=fine);
        }
    }
}

module impeller_blades(){
    impeller_blade();
    rotate(60) impeller_blade();
    rotate(120) impeller_blade();
}

module impeller_blade(){
    cube([blade_th,blade_width,blade_depth], center=true);
}

module impeller_lip(){
    difference(){
        cylinder(h=impeller_lip_th, r=impeller_od/2+tube_th, $fn=fine);
        translate([0,0,-1]) cylinder(h=impeller_lip_th+2, r=impeller_lip_hole_d/2, $fn=fine);
    }
}

//////////////////////////////////
// C a t c h e r s
//////////////////////////////////
module catcher(){
    //translate([0,0,0]){
    translate([0,0,impeller_h]){
        catcher_blade();
        rotate(90) catcher_blade();
    }
}

module catcher_blade(){
    cube([catcher_d,catcher_th,tube_len-impeller_h]);
    //cube([catcher_d,catcher_th,tube_len]);
}


//////////////////////////////////
// B a f f l e
//////////////////////////////////
module baffle(){

    // blades
    for (a=[0:45:360]){
        rotate(a) translate([baffle_clearance+tube_od/2+baffle_width/2,0,0]) baffle_blade();
    }

    // base
    %translate([0,0,-baffle_base_th*0.95]) baffle_base();

    }

module baffle_base(){
    translate([0,0,-baffle_depth/2]) {
        cylinder(h=baffle_base_th,r=baffle_clearance+baffle_width+tube_od/2);
    }
}

module baffle_blade(){
    cube([baffle_width,baffle_th,baffle_depth], center=true); // blade

    translate([0,0,-baffle_depth/2]){
        difference(){
            rotate([45,0,0]) cube([baffle_width,baffle_web_th,baffle_web_th], center=true); // blade support web
            translate([0,0,-baffle_web_th]) cube([baffle_width*1.2,2*baffle_web_th,2*baffle_web_th], center=true);
        }
    }
}


