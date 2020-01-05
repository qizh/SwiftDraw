//
//  LayerTree.Transform.swift
//  SwiftDraw
//
//  Created by Simon Whitty on 3/6/17.
//  Copyright 2020 WhileLoop Pty Ltd. All rights reserved.
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/swhitty/SwiftDraw
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

extension LayerTree {
  
  enum Transform: Equatable {
    case matrix(Matrix)
    case scale(sx: Float, sy: Float)
    case translate(tx: Float, ty: Float)
    case rotate(radians: Float)
    
    static var identity: Transform  {
      let m = Matrix(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
      return .matrix(m)
    }
    
    static func skewX(angle radians: Float) -> Transform  {
      let m = Matrix(a: 1, b: 0, c: tan(radians), d: 1, tx: 0, ty: 0)
      return .matrix(m)
    }
    
    static func skewY(angle radians: Float) -> Transform  {
      let m = Matrix(a: 1, b: tan(radians), c: 0, d: 1, tx: 0, ty: 0)
      return .matrix(m)
    }
    
    struct Matrix: Equatable {
      var a: Float
      var b: Float
      var c: Float
      var d: Float
      var tx: Float
      var ty: Float
    }
  }
}

extension LayerTree.Transform {
  func toMatrix() -> Matrix {
    switch self {
    case .matrix(let m):
      return m
    case .scale(let sx, let sy):
      return Matrix(a: sx, b: 0, c: 0, d: sy, tx: 0, ty: 0)
    case .translate(let tx, let ty):
      return Matrix(a: 1, b: 0, c: 0, d: 1, tx: tx, ty: ty)
    case .rotate(let radians):
      let sine = sin(radians)
      let cosine = cos(radians)
      return Matrix(a: cosine, b: sine, c: -sine, d: cosine, tx: 0, ty: 0)
    }
  }
}

extension LayerTree.Transform.Matrix {
  func concatenated(_ other: LayerTree.Transform.Matrix) -> LayerTree.Transform.Matrix {
    let (t, m) = (self, other)
    return LayerTree.Transform.Matrix(a: (t.a * m.a) + (t.b * m.c),
                                      b: (t.a * m.b) + (t.b * m.d),
                                      c: (t.c * m.a) + (t.d * m.c),
                                      d: (t.c * m.b) + (t.d * m.d),
                                      tx: (t.tx * m.a) + (t.ty * m.c) + m.tx,
                                      ty: (t.tx * m.b) + (t.ty * m.d) + m.ty)
  }
}
