// SPDX-License-Identifier: Apache-2.0
// netd's posix_spawn uses CLOEXEC_DEFAULT on a kernel lacking CLOEXEC support.
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <sys/syscall.h>
#include <unistd.h>

extern "C" int close_range(unsigned int first, unsigned int last, int flags) {
    int result = syscall(__NR_close_range, first, last, flags);
    if (result == 0 || (errno != EINVAL && errno != ENOSYS) || flags != 4 || first > last)
        return result;

    // Called after vfork: no allocation, locks, or modification of shared memory.
    int directory = syscall(__NR_openat, AT_FDCWD, "/proc/self/fd", O_RDONLY | O_DIRECTORY | O_CLOEXEC, 0);
    if (directory < 0) return -1;
    struct Entry {
        uint64_t ino;
        int64_t offset;
        unsigned short length;
        unsigned char type;
        char name[];
    };
    alignas(8) char buffer[4096];
    int error = 0;
    for (;;) {
        long count = syscall(__NR_getdents64, directory, buffer, sizeof(buffer));
        if (count == 0) break;
        if (count < 0) { if (errno == EINTR) continue; error = errno; break; }
        for (long pos = 0; pos < count;) {
            const auto* entry = reinterpret_cast<const Entry*>(buffer + pos);
            if (entry->length < 20 || pos + entry->length > count) { error = EIO; break; }
            unsigned int fd = 0;
            bool numeric = entry->name[0] != '\0';
            for (const char* c = entry->name; *c; ++c) {
                if (*c < '0' || *c > '9') { numeric = false; break; }
                fd = fd * 10 + (*c - '0');
            }
            if (numeric && fd >= first && fd <= last) {
                if (syscall(__NR_fcntl, fd, F_SETFD, FD_CLOEXEC) < 0 && errno != EBADF) {
                    error = errno;
                    break;
                }
            }
            pos += entry->length;
        }
        if (error) break;
    }
    syscall(__NR_close, directory);
    if (error) { errno = error; return -1; }
    return 0;
}
