// Copyright (c) 2011-2014 The Bitcoin Core developers
// Copyright (c) 2017-2019 The Raven Core developers
// Copyright (c) 2020-2021 The CmusicAI Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef CMUSICAI_QT_CMUSICAIADDRESSVALIDATOR_H
#define CMUSICAI_QT_CMUSICAIADDRESSVALIDATOR_H

#include <QValidator>

/** Base58 entry widget validator, checks for valid characters and
 * removes some whitespace.
 */
class CmusicAIAddressEntryValidator : public QValidator
{
    Q_OBJECT

public:
    explicit CmusicAIAddressEntryValidator(QObject *parent);

    State validate(QString &input, int &pos) const;
};

/** cmusicai address widget validator, checks for a valid cmusicai address.
 */
class CmusicAIAddressCheckValidator : public QValidator
{
    Q_OBJECT

public:
    explicit CmusicAIAddressCheckValidator(QObject *parent);

    State validate(QString &input, int &pos) const;
};

#endif // CMUSICAI_QT_CMUSICAIADDRESSVALIDATOR_H
