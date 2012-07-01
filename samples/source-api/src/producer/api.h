/* Copyright (c) 2012 Taylor Hutt, Logic Magicians Software
 *
 * This program is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/* This file declares a public, shared header file.  Modifying the
 * file will cause LMSBW to produce an error indicating that the
 * public API has been changed and that directly dependent components
 * must be rebuilt.
 */
#if !defined(__API_H)
#define __API_H

typedef struct sample_struct_t {
    unsigned a;
    float    b;
    char     ch;
} sample_struct_t;

void public_api(sample_struct_t *s);
#endif
