#!/usr/bin/env python3
"""split_seed_mask.py MASK N PREFIX: splits a seeding mask into N parts"""
import sys

import nibabel as nib
import numpy as np

mask_file, parts, prefix = sys.argv[1], int(sys.argv[2]), sys.argv[3]
img = nib.load(mask_file)
mask = np.asarray(img.dataobj) > 0
voxels = np.flatnonzero(mask.ravel())
assert parts >= 1 and voxels.size >= parts, "the mask has fewer seeding voxels than parts"

total = 0
for part in range(parts):
    out = np.zeros(mask.size, dtype=np.uint8)
    out[voxels[part::parts]] = 1
    total += int(out.sum())
    nib.save(nib.Nifti1Image(out.reshape(mask.shape), img.affine, img.header), "%s_%02d.nii.gz" % (prefix, part))
assert total == voxels.size, "the parts do not add up to the original mask"
