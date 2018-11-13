#!/usr/bin/env python
#

import os, sys, re, hashlib, time

try:
    dst=sys.argv[1]
except IndexError:
    print( 'Usage: %s <destination path>' % ( sys.argv[ 0 ] ) )

# regular expressions
file_type_re = re.compile( r'[.](jpg|jpeg|mov|wav|cr2|mp3|mp4|png|doc|docx|xls|xlsx|odt|ods|pdf|ppt|pptx|odp|zip)$',
                           re.I )

appdata_re = re.compile( r'/AppData/' )

for root, dirs, files in os.walk( ".", topdown = False ):
    m = appdata_re.search( root )
    if m:
        continue
    for name in files:
        m = file_type_re.search( name )
        if not m:
            continue
        m = appdata_re.search( name )
        if m:
            continue
        h = hashlib.sha1()
        f = os.path.join( root, name )
        try:
            fsock = open( f, 'rb' )
            h.update( fsock.read() )
            fsock.close()
            sha1 = h.hexdigest()
            dstpath=os.sep.join( [ dst,
                                   sha1[0:2],
                                   sha1[2:],
                                   os.path.basename( name ) ] )
            """
            don't forget to create dstpath
            """
            dstdir=os.path.dirname( dstpath )
            if not os.path.isdir( dstdir ):
                sys.stdout.write( 'create directory %s\n'
                                  % ( dstdir ) )
                os.makedirs( dstdir, 0775 )
            if not os.path.isfile( dstpath ):
                cmd=( 'cp --preserve=timestamps "%s" "%s"'
                      % ( f, dstpath ) )
                sys.stdout.write( cmd + '\n' )
                os.system( cmd )
        except KeyboardInterrupt:
            sys.exit( 0 )
        except IOError:
            pass
