/**
 * @file fcm.h
 * @author Stefano Magrini Alunno (stefanomagrini99@gmail.com)
 * @brief definition of cxxfcm and status code macros
 *
 * @date 2024-07-16
 *
 * @copyright Copyright (c) 2024
 */
#pragma once

#include <vector>

#define SUCCESS 0
#define LOGERROR 1


/**
 * @brief This function takes a datafile path and compute an fcm clustering
 *
 * @param[in] datafile_path: path of datafile
 * @param[in] outfile_path: path of output file
 * @param[in] centroids_path: path of file with initial centroids
 * @param[in] n_tiles: size of tiles
 * @param[in] log_path: path of log file
 *
 * @return int: status code
 */
int cxxfcm(
    const char *const datafile_path,
    const char *const outfile_path,
    const char *const centroids_path,
    int n_tiles,
    const char *const log_path);

/**
 * @brief This function takes a datafile path and compute an fcm clustering
 *
 * @param[in] data: vector of data
 * @param[in] centroids: vector of initial centroids
 * @param[in] n_tiles: size of tiles
 * @param[in] log_path: path of log file
 *
 * @return std::vector<float>: vector of centroids
 *
 * @exception std::bad_alloc : if the size of data is not valid
 *
 */
std::vector<float> cudafcm(
    const std::vector<float> &data,
    const std::vector<float> &centroids,
    const int n_tiles,
    const char *const log_path);