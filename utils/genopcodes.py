#!/usr/bin/python


f = open("opcodes")

lines = [x for x in filter(lambda x: False if x == '' else False if x[
                           0] == '#' else True, [x for x in f.read().splitlines()])]


def i_form(x):
    return ('{:0<6b}' + 26 * '?').format(x)


def b_form(x):
    return ('{:0<6b}' + 26 * '?').format(x)


def d_form(x):
    return ('{:0<6b}' + 26 * '?').format(x)


def x_form(x, y):
    return ('{:0<6b}' + 15 * '?' + '{:0<10b}?').format(x, y)


def xo_form(x, y):
    return ('{:0<6b}' + 15 * '?' + '?{:0<9b}?').format(x, y)


def xl_form(x, y):
    return ('{:0<6b}' + 15 * '?' + '{:0<10b}?').format(x, y)


print('`ifndef _Instructions\n`define _Instructions\npackage Instructions;')
for l in lines:
    x = l.split(" ")
    op = str.upper(x[0])
    s = x[1]
    r = ""
    if (s == "iform"):
        r = i_form(int(x[2]))
    if (s == "dform"):
        r = d_form(int(x[2]))
    if (s == "bform"):
        r = b_form(int(x[2]))
    if (s == "xform"):
        r = x_form(int(x[2]), int(x[3]))
    if (s == "xoform"):
        r = xo_form(int(x[2]), int(x[3]))
    if (s == "xlform"):
        r = xl_form(int(x[2]), int(x[3]))
    print('`define {:10} 32\'b{}'.format(str.upper(x[0]), r))
print('endpackage\n`endif')
