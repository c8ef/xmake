/*!The Make-like Build Utility based on Lua
 * 
 * XMake is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 * 
 * XMake is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with XMake; 
 * If not, see <a href="http://www.gnu.org/licenses/"> http://www.gnu.org/licenses/</a>
 * 
 * Copyright (C) 2015 - 2016, ruki All rights reserved.
 *
 * @author      ruki
 * @file        config.h
 *
 */
#ifndef XM_PREFIX_CONFIG_H
#define XM_PREFIX_CONFIG_H

/* //////////////////////////////////////////////////////////////////////////////////////
 * includes
 */
#include "../config.h"
#include "tbox/tbox.h"

/* //////////////////////////////////////////////////////////////////////////////////////
 * macros
 */

/*! @def __xm_small__
 *
 * small mode
 */
#if XM_CONFIG_SMALL
#   define __xm_small__
#endif

/*! @def __xm_debug__
 *
 * debug mode
 */
#ifdef __tb_debug__
#   define __xm_debug__
#endif

#endif


