#!/usr/bin/env python
#

import os, sys, re, hashlib, time

try:
    src, dst = sys.argv[1:3]
    if not ( os.path.isdir( src ) and os.path.isdir( dst ) ):
        raise IndexError
except:
    print( 'Usage: %s <src path> <dest path>' % ( sys.argv[ 0 ] ) )

# hash database
hashdb={
    'dirs' : {},
    'cmds' : {},
}

# regular expressions
file_type_re = re.compile( r'[.](jpg|jpeg|mov|wav|cr2|mp3|mp4|png|doc|docx|xls|xlsx|odt|ods|pdf|ppt|pptx|odp|zip)$',
                           re.I )

appdata_re = re.compile( r'/(AppData|[.][sS]team|Steam)/' )

for root, dirs, files in os.walk( src, topdown = False ):
    m = appdata_re.search( root )
    if m:
        continue
    for name in files:
        """
        skip any file types we don't care about
        """
        m = file_type_re.search( name )
        if not m:
            continue
        """
        skip any directories or file paths we don't care about
        """
        m = appdata_re.search( name )
        if m:
            continue
        """
        initi the hash for the file
        """
        h = hashlib.sha1()
        f = os.path.join( root, name )
        try:
            fsock = open( f, 'rb' )
            h.update( fsock.read() )
            fsock.close()
            sha1 = h.hexdigest()
            """
            this is the destination path
            """
            dstpath = os.path.join( dst,
                                    sha1[0:2],
                                    sha1[2:],
                                    os.path.basename( name ) )
            """
            don't forget to create dstpath
            """
            dstdir = os.path.dirname( dstpath )
            hashdb[ 'dirs' ][ dstdir ] = 1
#            cmd=( 'cp --preserve=timestamps "%s" "%s"'
#                  % ( f, dstpath ) )
            cmd=( 'cp -f "%s" "%s"'
                  % ( f, dstpath ) )
            hashdb[ 'cmds' ][ cmd ] = 1
        except KeyboardInterrupt:
            sys.exit( 0 )
        except IOError:
            pass

"""
print the bash header
"""
print( '#!/bin/bash' )
print( '#' )
print()

"""
now create the directories and copy the files
"""
dirs = sorted( hashdb[ 'dirs' ].keys() )
while dirs:
    cmd = ' '.join( [ 'mkdir', '-vp', '' ] )
    if ( 50 > len( dirs ) ):
        cmd += ' '.join( dirs )
        dirs = []
    else:
        cmd += ' '.join( dirs[ 0 : 50 ] )
        dirs = dirs[ 50: ]
    print( cmd )

"""
now copy the files
"""
for cmd in sorted( hashdb[ 'cmds' ].keys() ):
    print( cmd )
