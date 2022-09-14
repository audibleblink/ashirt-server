// Copyright 2020, Verizon Media
// Licensed under the terms of the MIT. See LICENSE file in project root for terms.

import * as React from 'react'
import Card from 'src/components/card'
import OperationBadges from 'src/components/operation_badges'
import classnames from 'classnames/bind'
import { Link } from 'react-router-dom'
import { OperationStatus } from 'src/global_types'
import Button from 'src/components/button'
import { setFavorite } from 'src/services'
const cx = classnames.bind(require('./stylesheet'))

export default (props: {
  className?: string,
  slug: string,
  name: string,
  numUsers: number,
  status: OperationStatus,
  favorite?: boolean,
}) => {
  const [isFavorite, setIsFavorite] = React.useState(props.favorite || false)

  React.useEffect(() => {
    setFavorite(props.slug, isFavorite)
  }, [isFavorite, props.slug])

  return (
    <Card className={cx('root', props.className)}>
      <Link className={cx('name')} to={`/operations/${props.slug}/evidence`}>{props.name}</Link>
      <OperationBadges className={cx('badges')} numUsers={props.numUsers} status={props.status} />
      <Link className={cx('edit')} to={`/operations/${props.slug}/edit`} title="Edit this operation" />
      <Link className={cx('overview')} to={`/operations/${props.slug}/overview`} title="Evidence Overview" />
      <Button
        className={isFavorite ? cx('favorite'): cx('not-favorite')}
        onClick={() => setIsFavorite(!isFavorite)}>
      </Button>
    </Card>
    )
  }
