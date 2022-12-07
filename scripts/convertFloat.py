#!/usr/bin/env python3

#*-------------------------------------------*#
#  Title       : Format Converter             #
#  File        : convertFloat.py              #
#  Author      : Yigit Suoglu                 #
#  License     : EUPL-1.2                     #
#  Last Edit   : 07/12/2022                   #
#*-------------------------------------------*#
#  Description : Generate floating point num  #
#                from parts                   #
#*-------------------------------------------*#

import sys
import math

def printHelp():
  print("convertFloat.py [-f <32/64>] <<sign> <exponent> <fraction> | <float>>" )


def convert():
  partsHave=0
  sign=0
  exponent=0
  fraction=0
  formatChosen = 32 #default
  gettingFormat=False
  if len(sys.argv) < 2:
    printHelp()
    return ""
  elif len(sys.argv) > 1:
    while len(sys.argv) > 1:
      current = sys.argv.pop(1)
      current = current.strip()
      if gettingFormat:
        if current == "32" or current == "64":
          formatChosen=current
          gettingFormat=False
          continue
        else:
          print("Only 32 and 64 is supported for format!")
          return "error"
      else:
        if current == '-f':
          gettingFormat=True
          continue
        elif partsHave == 0:
          sign=float(current)
        elif partsHave == 1:
          exponent=int(current)
        else:
          fraction=int(current)
        partsHave+=1
    if partsHave == 1:
      floatVal = sign
      if floatVal == 0:
        sign = 1
        exponent = 0
        fraction = 0
      elif floatVal < 0:
        sign = -1
        floatVal*=-1
      else:
        sign = 1
      if floatVal != 0:
        exponent=math.log2(floatVal)
        if exponent < 0:
          exponent=int(exponent-0.5)
        else:
          exponent=int(exponent)
        if formatChosen == 32:
          if exponent < -126:
            exponent = -126
        else:
          if exponent < -1022:
            exponent = -1022
        floatVal/=math.pow(2, exponent)
        if floatVal < 1:
          exponent-=1
        else:
          floatVal-=1
        if formatChosen == 32:
          fraction=int(floatVal*math.pow(2,23)+0.5)
          exponent+=127
        else:
          fraction=int(floatVal*math.pow(2,52)+0.5)
          exponent+=1023
      print("sign:", sign, "exp:", exponent, "frac:", fraction)
    else:
      if math.pow(sign,2) != 1.0:
        print("Sign can only be -1 or 1!")
        return "error"
      print("got", sign, ",", exponent,",", fraction)
    integerPart = 1.0
    if exponent == 0:
      integerPart = 0.0
    if formatChosen == 32:
      exponent = exponent - 126 - integerPart
      integerPart+=(fraction/math.pow(2, 23))
    else:
      exponent = exponent - 1022 - integerPart
      integerPart+=(fraction/math.pow(2, 52))
    return  sign * integerPart * math.pow(2, exponent)


#Main function
if __name__ == '__main__':
  print(str(convert()))
