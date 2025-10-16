# Failing Tests Tracking

## Status: In Progress

Last Updated: 2025-10-16

## P0 - Blocking Issues

### 1. GPG Key Verification Failure on RHEL-based Platforms

**Affected Suites**: All suites on RHEL-based platforms (centos-stream-9, rockylinux-*, almalinux-*, oraclelinux-*)

**Platforms Affected**:

- centos-stream-9
- centos-stream-10
- rockylinux-8
- rockylinux-9
- rockylinux-10
- almalinux-8
- almalinux-9
- almalinux-10
- oraclelinux-8
- oraclelinux-9

**Error Message**:
```
Public key for postgresql16-16.10-1PGDG.rhel9.aarch64.rpm is not installed
GPG Keys are configured as: file:///etc/pki/rpm-gpg/PGDG-RPM-GPG-KEY
Error: GPG check FAILED
```

**Root Cause**: 
The GPG key file is created via `remote_file` resource, but DNF doesn't immediately trust it. The key needs to be imported into the RPM database before package installation.

**Reproduction Steps**:
```bash
kitchen test ident-16-centos-stream-9
```

**Fix Strategy**:
- Import GPG key into RPM database using `rpm --import` after downloading
- Add execute resource to import key before yum_repository resources
- Ensure key is imported during :repository action

**Priority**: P0 - Blocks all RHEL testing

**Status**: Identified, fix in progress

---

### 2. Ident Authentication Test Failure (CI Only)

**Affected Suites**: ident-* suites

**Platforms Affected**: 
- Seen in CI on centos-stream-9 (from CI logs)
- **NOT reproducible locally on debian-12** (test passes)
- Need to verify on RHEL platforms once GPG issue is fixed

**Error Message** (from CI):
```
Command: `sudo -u shef bash -c "psql -U sous_chef -d postgres -c 'SELECT 1;'"`
exit_status is expected to eq 0
got: 1
```

**Root Cause**: Unknown - may be related to:
- Service reload vs restart for ident changes
- Timing issue with ident file application
- Platform-specific peer authentication behavior

**Reproduction Steps**:
```bash
# Passes locally:
kitchen test ident-16-debian-12

# Need to test on RHEL after fixing GPG issue:
kitchen test ident-16-centos-stream-9
```

**Fix Strategy**:
- First fix GPG issue to test on RHEL platforms
- Compare working Debian vs failing RHEL behavior
- May need to change from `:reload` to `:restart` for ident changes
- Add verification step before testing authentication

**Priority**: P0 - Blocks ident test suite

**Status**: Needs investigation after GPG fix

---

## P1 - Important but Not Blocking

None identified yet.

---

## P2 - Nice to Fix

None identified yet.

---

## Test Results Summary

### Passing Platforms
- debian-12 (ident-16 suite confirmed passing)
- ubuntu-* (likely passing, not yet tested)

### Failing Platforms  
- All RHEL-based platforms (GPG issue)

### Not Yet Tested
- amazonlinux-2023
- fedora-latest
- opensuse-leap-15

---

## Next Steps

1. ✅ Document failing tests (this file)
2. 🔄 Fix GPG key import issue for RHEL platforms
3. ⏳ Re-test ident suite on RHEL after GPG fix
4. ⏳ Audit remaining test suites for other failures
5. ⏳ Run full test matrix on representative platforms
